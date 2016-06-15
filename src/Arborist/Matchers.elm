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
