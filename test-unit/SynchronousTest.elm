module SynchronousTest exposing (tests)

import Task exposing (Task)

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
        assert a (not_ (equals b))
    ),

    test "sync: can match results" (
      let
        a = Ok "foo" |> fromResult
        b = Ok "foo" |> fromResult
      in
        assert a (equals b)
    ),

    test "sync: recognises test failures" (
      let
        a = Ok "Nope." |> fromResult
        b = Ok "foo" |> fromResult
      in
        assert (assert a (equals b)) (equals (Task.succeed (False, [
          ("Expected", "\"foo\""),
          ("Actual", "\"Nope.\"")
        ])))
    ),

    test "sync: recognises test errors" (
      let
        a = Err "Oh no!" |> fromResult
        b = Ok "foo" |> fromResult
      in
        assert (assert a (equals b)) (failsWith [
          ("Error", "\"Oh no!\""),
          ("Expected", "\"foo\""),
          ("Actual", "Error: \"Oh no!\"")
        ])
    )
  ]

fromResult : Result a b -> Task a b
fromResult result =
  case result of
    Ok value -> Task.succeed value
    Err error -> Task.fail error
