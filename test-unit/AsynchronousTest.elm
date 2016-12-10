module AsynchronousTest exposing (tests)

import Process
import Task

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)

tests : Tests
tests =
  [
    test "async: waits for tasks to succeed" (
      let
        a = Process.sleep 100 |> Task.andThen (always (Task.succeed 42))
        b = Task.succeed 42
      in
        assert a (equals b)
    ),

    test "async: waits for tasks to fail" (
      let
        a = Process.sleep 100 |> Task.andThen (always (Task.fail "Well, that didn't work."))
        b = Task.fail "Well, that didn't work."
      in
        assert (assert a (equals b)) fails
    ),

    test "async: fails even if one of the tasks succeeds" (
      let
        a = Process.sleep 100 |> Task.andThen (always (Task.fail "That didn't either."))
        b = Task.succeed "What?"
      in
        assert (assert a (equals b)) fails
    )
  ]
