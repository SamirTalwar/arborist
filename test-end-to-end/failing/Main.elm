port module Main exposing (main)

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)
import Task

port output : TestResult -> Cmd message

main : Program Never
main = run tests output

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
    )
  ]
