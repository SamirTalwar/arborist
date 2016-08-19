module SynchronousTest exposing (tests)

import Task

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)

tests : Tests
tests =
  [
    test "sync: a simple test that always passes" pass,

    test "sync: performs simple equality checks" (
      let
        a = True |> Task.succeed
        b = True |> Task.succeed
      in
        assert a (equals b)
    ),

    test "sync: recognises negation" (
      let
        a = True |> Task.succeed
        b = False |> Task.succeed
      in
        assert a (not' (equals b))
    ),

    test "sync: can match results" (
      let
        a = Ok "foo" |> Task.fromResult
        b = Ok "foo" |> Task.fromResult
      in
        assert a (equals b)
    ),

    test "sync: recognises test failures" (
      let
        a = Ok "Nope." |> Task.fromResult
        b = Ok "foo" |> Task.fromResult
      in
        assert (assert a (equals b)) (equals (Task.succeed (False, [
          ("Expected", "\"foo\""),
          ("Actual", "\"Nope.\"")
        ])))
    ),

    test "sync: recognises test errors" (
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
