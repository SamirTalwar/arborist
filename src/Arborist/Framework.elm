module Arborist.Framework exposing (
    Test,
    Tests,
    Name,
    Assertion,
    FailureMessage,
    FailureMessages,
    run,
    test,
    assert
  )

import List
import String
import Task exposing (Task)

import Arborist.Assertions
import Arborist.Matchers exposing (Matcher)
import Native.Arborist.Framework

type alias Name = String

type Test = Test { name : Name, assertion : Assertion }

type alias Tests = List Test

type alias Assertion = Arborist.Assertions.Assertion
type alias FailureMessage = Arborist.Assertions.FailureMessage
type alias FailureMessages = Arborist.Assertions.FailureMessages

test : Name -> Assertion -> Test
test name assertion =
  Test { name = name, assertion = assertion }

run : List Test -> Cmd ()
run tests =
  tests
    |> List.reverse
    |> List.map (\(Test { name, assertion }) ->
      assertion
        |> Task.map (\(testPassed, failureMessages) ->
          if testPassed
            then passed name
            else failed name failureMessages)
        |> (flip Task.onError) (\failureMessages -> Task.succeed (failed name failureMessages))
        |> Task.perform runTest runTest)
    |> Cmd.batch

runTest : String -> ()
runTest = Native.Arborist.Framework.runTest >> always ()

assert : Task a b -> Matcher a b -> Assertion
assert = Arborist.Assertions.assert

passed : Name -> String
passed name = green (name ++ " PASSED")

failed : Name -> FailureMessages -> String
failed name failureMessages =
  failureMessages
    |> List.map (\(key, value) -> "\n  " ++ key ++ ":\n  " ++ value)
    |> String.join ""
    |> (\messages -> name ++ " FAILED" ++ messages)
    |> red

green string = "\x1b[32m" ++ string ++ reset

red string = "\x1b[31m" ++ string ++ reset

reset = "\x1b[0m"
