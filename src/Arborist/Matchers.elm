module Arborist.Matchers exposing (..)

{-| Provides a set of matchers used for assertions.

# Types
@docs Matcher

# Matchers
@docs equals, isIntBetween
@docs not_

# Helpers

The helpers are generally only to be used when constructing your own matchers.

@docs fails, failsWith
@docs onFailure, sequenceMessages

-}

import Arborist.Assertions exposing (..)

import Task exposing (Task)

{-| A matcher is a function that accepts a value and asserts some property about it.
-}
type alias Matcher a b = Task a b -> Assertion

{-| Negates another matcher.

    assert (Task.succeed 3) (not_ (equals (Task.succeed 4)))
-}
not_ : Matcher a b -> Matcher a b
not_ matcher actual =
  matcher actual |> Task.map (\(result, failureMessages) -> (not result, failureMessages))

{-| Asserts that two values are equal.

    assert (Task.succeed "Hello!") (equals (Task.succeed "Hello!"))
-}
equals : Task a b -> Matcher a b
equals expected actual =
  Task.map2 (==) expected actual |> onFailure (sequenceMessages [
    ("Expected", expected),
    ("Actual", actual)
  ])

{-| Asserts an integer is between two others, inclusive.

    assert (Task.succeed 24) (isIntBetween (Task.succeed 12) (Task.succeed 36))
-}
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

{-| Asserts that another assertion fails.

    assert (assert (Task.succeed 1) (equals (Task.succeed 2))) fails
-}
fails : Matcher FailureMessages (Bool, FailureMessages)
fails assertion =
  assertion
    |> Task.map (\(result, failureMessages) -> (not result, failureMessages))
    |> Task.onError (\failureMessages -> Task.succeed (True, failureMessages))

{-| Asserts that another assertion fails with specific failure messages.

    assert (assert (Task.succeed True) (equals (Task.succeed False))) failsWith [
      ("Expected", False),
      ("Actual", True)
    ]
-}
failsWith : FailureMessages -> Matcher FailureMessages (Bool, FailureMessages)
failsWith expected assertion =
  assertion
    |> Task.andThen (\(result, actual) ->
        if result
          then Task.succeed (False, ("Error", "Unexpected success") :: actual)
          else assert (Task.succeed actual) (equals (Task.succeed expected)))
    |> Task.onError (\actual -> assert (Task.succeed actual) (equals (Task.succeed expected)))

{-| When constructing a matcher, adds failure messages.

If the matching operation results in an error, the error message is included in
the failure messages as the first item, with a name of "Error".

This function is often used with `sequenceMessages`.

    equals : Task a b -> Matcher a b
    equals expected actual =
      Task.map2 (==) expected actual |> onFailure (sequenceMessages [
        ("Expected", expected),
        ("Actual", actual)
      ])
-}
onFailure : Task a FailureMessages -> Task a Bool -> Assertion
onFailure messages result =
  let
    recoveredMessages = messages |> Task.onError (\error -> Task.succeed [("Error", toString error)])
  in
    Task.map2 (,) result recoveredMessages
      |> Task.onError (\error ->
        recoveredMessages
          |> Task.andThen (\ms ->
            Task.fail (("Error", toString error) :: ms)))

{-| Converts a list of failure messages which have value tasks into a task of failure messages.

    let
      a = Task.succeed 1
      b = Task.succeed 2
    in
      assert (sequenceMessages [("A", a), ("B", b)]) (equals (Task.succeed [("A", 1), ("B", 2)]))
-}
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
      |> List.map (Task.map Ok)
      |> List.map (Task.onError (Err >> Task.succeed))
      |> Task.sequence
      |> Task.map (\values -> List.map2 (,) names (List.map resultToString values))
