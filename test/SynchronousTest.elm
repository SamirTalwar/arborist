module SynchronousTest exposing (tests)

import Task

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)

tests : Tests
tests =
  [
    test "performs simple equality checks" (
      let
        a = True |> Task.succeed
        b = True |> Task.succeed
      in
        assert a (equals b)
    ),

    test "recognises negation" (
      let
        a = True |> Task.succeed
        b = False |> Task.succeed
      in
        assert a (not' (equals b))
    ),

    test "can match results" (
      let
        a = Ok "foo" |> Task.fromResult
        b = Ok "foo" |> Task.fromResult
      in
        assert a (equals b)
    ),

    test "recognises test failures" (
      let
        a = Ok "Nope." |> Task.fromResult
        b = Ok "foo" |> Task.fromResult
      in
        assert (assert a (equals b)) (equals (Task.succeed (False, [
          ("Expected", "\"foo\""),
          ("Actual", "\"Nope.\"")
        ])))
    ),

    test "recognises test errors" (
      let
        a = Err "Oh no!" |> Task.fromResult
        b = Ok "foo" |> Task.fromResult
      in
        assert (assert a (equals b)) (failsWith [
          ("Error", "\"Oh no!\""),
          ("Expected", "\"foo\""),
          ("Actual", "Error: \"Oh no!\"")
        ])
    )
  ]

failsWith : FailureMessages -> Matcher FailureMessages (Bool, FailureMessages)
failsWith expected assertion =
  assertion `Task.onError` (\actual -> assert (Task.succeed actual) (equals (Task.succeed expected)))
