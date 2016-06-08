port module Arborist.Framework exposing (
    Assertion,
    Name,
    Test,
    Tests,
    run,
    test,
    assert,
    equals,
    isIntBetween
  )

import List
import String
import Task exposing (Task)

import Native.Arborist.Framework

type alias Name = String

type alias FailureMessage = (String, Task String String)

type alias Assertion = (Task String Bool, List FailureMessage)

type alias Matcher a b = Task a b -> Assertion

type Test = Test { name : Name, assertion : Assertion }

type alias Tests = List Test

test : Name -> Assertion -> Test
test name (assertion, failureMessages) =
  Test { name = name, assertion = (assertion, failureMessages) }

run : List Test -> Cmd message
run tests =
  (flip List.map) tests (\(Test { name, assertion }) ->
    let
      (task, failureMessages) = assertion
    in
      task
      `Task.andThen` (\testPassed ->
        if testPassed
          then Task.succeed (passed name)
          else failed name failureMessages)
      `Task.onError` (\error -> failed name ([("Error", Task.fail error)] ++ failureMessages))
      |> Task.perform identity Native.Arborist.Framework.runTest
  )
  |> Cmd.batch

assert : Task a b -> Matcher a b -> Assertion
assert actual matcher = matcher actual

equals : Task a b -> Matcher a b
equals expected actual =
  (Task.map2 (==) expected actual |> readableErrors,
   [("Expected", stringTask expected),
    ("Actual", stringTask actual)])

isIntBetween : Task a Int -> Task a Int -> Matcher a Int
isIntBetween lower upper actual =
  (Task.map3 (\l u a -> a > l && a < u) lower upper actual |> readableErrors,
   [("Actual", stringTask actual),
    ("Lower", stringTask lower),
    ("Upper", stringTask upper)])

stringTask task =
  task
    |> Task.map toString
    |> Task.mapError toString

readableErrors = Task.mapError toString

passed name = green (name ++ " PASSED")

failed name failureMessages =
  failureMessages
    |> List.map (\(key, valueTask) -> Task.map (renderMessage key) (Task.toResult valueTask))
    |> Task.sequence
    |> Task.map (String.join "")
    |> Task.map (\messages -> name ++ " FAILED" ++ messages)
    |> Task.map red

renderMessage key value =
  "\n  " ++ key ++ ":\n  " ++ case value of
    Ok ok -> ok
    Err err -> "Error: " ++ err

green string = "\x1b[32m" ++ string ++ reset

red string = "\x1b[31m" ++ string ++ reset

reset = "\x1b[0m"
