module Arborist.Matchers exposing (..)

import Arborist.Assertions exposing (..)

import Task exposing (Task)

type alias Matcher a b = Task a b -> Assertion

not' : Matcher a b -> Matcher a b
not' matcher actual =
  matcher actual |> Task.map (\(result, failureMessages) -> (not result, failureMessages))

equals : Task a b -> Matcher a b
equals expected actual =
  Task.map2 (==) expected actual |> onFailure (sequenceMessages [
    ("Expected", expected),
    ("Actual", actual)
  ])

isIntBetween : Task a Int -> Task a Int -> Matcher a Int
isIntBetween lower upper actual =
  Task.map3 (\l u a -> l <= a && a <= u) lower upper actual
    |> onFailure (
      (Task.map2 (\l u ->
        if l <= u
          then []
          else [("Error", (toString l) ++ " is greater than " ++ (toString u))]
        ) lower upper)
        |> Task.map2 (\messages error -> error ++ messages) (sequenceMessages [
             ("Lower", lower),
             ("Upper", upper),
             ("Actual", actual)
           ]))

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

onFailure : Task a FailureMessages -> Task a Bool -> Assertion
onFailure messages result =
  let
    recoveredMessages = messages `Task.onError` \error -> Task.succeed [("Error", toString error)]
  in
    Task.map2 (,) result recoveredMessages
      `Task.onError` \error ->
        recoveredMessages
          `Task.andThen` \ms ->
            Task.fail (("Error", toString error) :: ms)

sequenceMessages : List (String, Task a b) -> Task never FailureMessages
sequenceMessages messageTasks =
  let
    resultToString result =
      case result of
        Ok value -> toString value
        Err error -> "Error: " ++ toString error
    (names, valueTasks) = List.unzip messageTasks
  in
    valueTasks
      |> List.map Task.toResult
      |> Task.sequence
      |> Task.map (\values -> List.map2 (,) names (List.map resultToString values))
