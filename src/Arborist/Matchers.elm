module Arborist.Matchers exposing (..)

import Arborist.Assertions exposing (..)

import Task exposing (Task)

type alias Matcher a b = Task a b -> Assertion

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

fails : Matcher FailureMessages (Bool, FailureMessages)
fails assertion =
  assertion
    |> Task.map (\(result, failureMessages) -> (not result, failureMessages))
    |> (flip Task.onError) (\failureMessages -> Task.succeed (True, failureMessages))

failsWith : FailureMessages -> Matcher FailureMessages (Bool, FailureMessages)
failsWith expected assertion =
  assertion
    `Task.andThen` (\(result, actual) ->
        if result
          then Task.succeed (False, ("Error", "Unexpected success") :: actual)
          else assert (Task.succeed actual) (equals (Task.succeed expected)))
    `Task.onError` (\actual -> assert (Task.succeed actual) (equals (Task.succeed expected)))

onFailure : List (String, Task a b) -> Task c Bool -> Assertion
onFailure messageTasks result =
  let
    (names, valueTasks) = List.unzip messageTasks
    messages = valueTasks
      |> List.map Task.toResult
      |> Task.sequence
      |> Task.map (\values -> List.map2 (,) names (List.map resultToString values))
    resultToString result =
      case result of
        Ok value -> toString value
        Err error -> "Error: " ++ toString error
  in
    Task.map2 (,) result messages
      `Task.onError` (\error -> messages `Task.andThen` (\ms -> Task.fail (("Error", toString error) :: ms)))
