port module Arborist.Run_${randomNumber} exposing (main)

import ${testModule} exposing (${testFunction})

import Arborist.Assertions exposing (FailureMessages)
import Arborist.Framework exposing (Test (..))
import Task

type alias Name = String

type alias TestResult = { passed : Bool, name : Name, failureMessages : FailureMessages }

port output : TestResult -> Cmd message

main : Program Never () TestResult
main = run tests output

run : List Test -> (TestResult -> Cmd TestResult) -> Program Never () TestResult
run tests output =
  Platform.program {
    init = ((), constructTests tests),
    update = \message model -> ((), output message),
    subscriptions = always Sub.none
  }

constructTests : List Test -> Cmd TestResult
constructTests tests =
  tests
    |> List.reverse
    |> List.map (\(Test name assertion) ->
      Task.attempt (check name) assertion)
    |> Cmd.batch

check : Name -> Result FailureMessages (Bool, FailureMessages) -> TestResult
check name result =
  case result of
    Ok (True, _) -> passed name
    Ok (False, failureMessages) -> failed name failureMessages
    Err failureMessages -> failed name failureMessages

passed : Name -> TestResult
passed name = { passed = True, name = name, failureMessages = [] }

failed : Name -> FailureMessages -> TestResult
failed name failureMessages = { passed = False, name = name, failureMessages = failureMessages }
