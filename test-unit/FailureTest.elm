module FailureTest exposing (tests)

import Task

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)

tests : Tests
tests =
  [
    test "failure: explicit failures fail" (
      assert fail <| failsWith [("State", "Fail")]
    ),

    test "failure: explicit failures can fail with a reason" (
      assert (failWith "It broke.") <| failsWith [("State", "Fail"), ("Message", "It broke.")]
    ),

    test "failure: recognises assertion failure" (
      let
        a = Ok "one" |> Task.fromResult
        b = Ok "two" |> Task.fromResult
      in
        assert (assert a (equals b)) fails
    ),

    test "failure: recognises task failure" (
      let
        a = Err "Uh oh." |> Task.fromResult
        b = Ok "What happened?" |> Task.fromResult
      in
        assert (assert a (equals b)) fails
    ),

    test "failure: fails if the assertion is successful" (
      let
        success = assert (Task.succeed 100) (equals (Task.succeed 100))
      in
        assert (assert success fails) fails
    ),

    test "failure: recognises assertion failure" (
      let
        a = Ok "one" |> Task.fromResult
        b = Ok "two" |> Task.fromResult
      in
        assert (assert a (equals b)) (failsWith [
          ("Expected", "\"two\""),
          ("Actual", "\"one\"")
        ])
    ),

    test "failure: recognises task failure" (
      let
        a = Err "Uh oh." |> Task.fromResult
        b = Ok "What happened?" |> Task.fromResult
      in
        assert (assert a (equals b)) (failsWith [
          ("Error", "\"Uh oh.\""),
          ("Expected", "\"What happened?\""),
          ("Actual", "Error: \"Uh oh.\"")
        ])
    ),

    test "failure: fails if the assertion is successful" (
      let
        success = assert (Task.succeed 100) (equals (Task.succeed 100))
      in
        assert (assert success (failsWith [])) (failsWith [
          ("Error", "Unexpected success"),
          ("Expected", "100"),
          ("Actual", "100")
        ])
    )
  ]
