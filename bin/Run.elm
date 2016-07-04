port module Arborist.Run_${randomNumber} exposing (main)

import ${testModule} exposing (${testFunction})

import Arborist.Assertions exposing (FailureMessages)
import Arborist.Framework exposing (Test (..))
import Html
import Html.App exposing (program)
import Task

type alias Name = String

type alias TestResult = { passed : Bool, name : Name, failureMessages : FailureMessages }

port output : TestResult -> Cmd message

main : Program Never
main = run tests output

run : List Test -> (TestResult -> Cmd TestResult) -> Program Never
run tests output =
  program {
    init = ((), constructTests tests),
    update = \message model -> ((), output message),
    view = \model -> Html.div [] [],
    subscriptions = always Sub.none
  }

constructTests : List Test -> Cmd TestResult
constructTests tests =
  tests
    |> List.reverse
    |> List.map (\(Test name assertion) ->
      Task.perform (failed name) (uncurry (check name)) assertion)
    |> Cmd.batch

check : Name -> Bool -> FailureMessages -> TestResult
check name testPassed failureMessages =
  if testPassed
    then passed name
    else failed name failureMessages

passed : Name -> TestResult
passed name = { passed = True, name = name, failureMessages = [] }

failed : Name -> FailureMessages -> TestResult
failed name failureMessages = { passed = False, name = name, failureMessages = failureMessages }
