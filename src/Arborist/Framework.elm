port module Arborist.Framework exposing (
    Assertion,
    Name,
    Test,
    Tests,
    run,
    test,
    assert,
    not',
    equals,
    isIntBetween
  )

import List
import String
import Task exposing (Task)

import Native.Arborist.Framework

type alias Name = String

type alias FailureMessages = List FailureMessage

type alias FailureMessage = (String, String)

type alias Assertion = Task FailureMessages (Bool, FailureMessages)

type alias Matcher a b = Task a b -> Assertion

type Test = Test { name : Name, assertion : Assertion }

type alias Tests = List Test

test : Name -> Assertion -> Test
test name assertion =
  Test { name = name, assertion = assertion }

run : List Test -> Cmd String
run tests =
  (flip List.map) tests (\(Test { name, assertion }) ->
    assertion
    |> Task.map (\(testPassed, failureMessages) ->
      if testPassed
        then passed name
        else failed name failureMessages)
    |> Task.mapError (\failureMessages -> failed name failureMessages)
    |> Task.perform identity Native.Arborist.Framework.runTest
  )
  |> Cmd.batch

assert : Task a b -> Matcher a b -> Assertion
assert actual matcher = matcher actual

not' : Matcher a b -> Matcher a b
not' matcher actual =
  matcher actual |> Task.map (\(result, failureMessages) -> (not result, failureMessages))

equals : Task a b -> Matcher a b
equals expected actual =
  Task.map2 (==) expected actual |> onFailure [
    ("Expected", expected),
    ("Actual", actual)
  ]

isIntBetween : Task a Int -> Task a Int -> Matcher a Int
isIntBetween lower upper actual =
  Task.map3 (\l u a -> a > l && a < u) lower upper actual |> onFailure [
    ("Lower", lower),
    ("Upper", upper),
    ("Actual", actual)
  ]

onFailure : List (String, Task a b) -> Task c Bool -> Assertion
onFailure messageTasks result =
  let
    messages = sequenceMessages messageTasks
  in
    Task.map2 (,) result messages
      `Task.onError` (\error -> messages `Task.andThen` (\ms -> Task.fail (("Error", toString error) :: ms)))

sequenceMessages : List (String, Task a b) -> Task c FailureMessages
sequenceMessages messageTasks =
  let
    (names, valueTasks) = List.unzip messageTasks
  in
    valueTasks
      |> List.map Task.toResult
      |> Task.sequence
      |> Task.map (\values -> List.map2 (,) names (List.map resultToString values))

resultToString result =
  case result of
    Ok value -> toString value
    Err error -> "Error: " ++ toString error

passed name = green (name ++ " PASSED")

failed name failureMessages =
  failureMessages
    |> List.map (\(key, value) -> "\n  " ++ key ++ ":\n  " ++ value)
    |> String.join ""
    |> (\messages -> name ++ " FAILED" ++ messages)
    |> red

green string = "\x1b[32m" ++ string ++ reset

red string = "\x1b[31m" ++ string ++ reset

reset = "\x1b[0m"
