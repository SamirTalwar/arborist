port module Main exposing (main)

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)
import Process
import Task

port output : TestResult -> Cmd message

main : Program Never
main = run tests output

tests : List Test
tests =
  [
    test "performs simple equality checks" (
      let
        a = True |> Task.succeed
        b = True |> Task.succeed
      in
        assert a (equals b)
    ),

    test "negates matchers" (
      let
        a = True |> Task.succeed
        b = False |> Task.succeed
      in
        assert a (not' (equals b))
    ),

    test "verifies that an integer is between two others" (
      assert (Task.succeed 88) (isIntBetween (Task.succeed 77) (Task.succeed 99))
    ),

    test "waits for tasks to succeed" (
      let
        a = Process.sleep 100 `Task.andThen` always (Task.succeed 42)
        b = Task.succeed 42
      in
        assert a (equals b)
    ),

    test "waits for tasks to fail" (
      let
        a = Process.sleep 100 `Task.andThen` always (Task.fail "Well, that didn't work.")
        b = Task.fail "Well, that didn't work."
      in
        assert (assert a (equals b)) fails
    )
  ]
