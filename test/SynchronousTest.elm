module SynchronousTest exposing (tests)

import Task

import Arborist.Framework exposing (..)

tests : Tests
tests =
  [
    test "performs simple equality checks" (
      let
        a = True |> Task.succeed
        b = True |> Task.succeed
      in
        assert a (equals b)
    )
  ]
