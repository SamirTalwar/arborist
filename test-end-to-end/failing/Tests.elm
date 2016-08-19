module Test.Arborist.EndToEnd.Failing exposing (tests)

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)
import Task

tests : List Test
tests =
  [
    test "some tests pass" (
      let
        a = True |> Task.succeed
        b = True |> Task.succeed
      in
        assert a (equals b)
    ),

    test "but some tests fail" (
      let
        a = True |> Task.succeed
        b = False |> Task.succeed
      in
        assert a (equals b)
    ),

    test "and some tests *always* fail" fail
  ]
