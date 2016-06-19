module BetweenTest exposing (tests)

import Task

import Arborist.Framework exposing (..)
import Arborist.Matchers exposing (..)

tests : Tests
tests =
  [
    test "isIntBetween: verifies that an integer is between two others" (
      assert (Task.succeed 88) (isIntBetween (Task.succeed 77) (Task.succeed 99))
    ),

    test "isIntBetween: fails if the actual value is lower than the lower value" (
      assert (assert (Task.succeed 12) (isIntBetween (Task.succeed 34) (Task.succeed 56))) (failsWith [
        ("Lower", "34"),
        ("Upper", "56"),
        ("Actual", "12")
      ])
    ),

    test "isIntBetween: fails if the actual value is higher than the upper value" (
      assert (assert (Task.succeed -9) (isIntBetween (Task.succeed -100) (Task.succeed -50))) (failsWith [
        ("Lower", "-100"),
        ("Upper", "-50"),
        ("Actual", "-9")
      ])
    ),

    test "isIntBetween: fails with an error if the lower value is greater than the upper value" (
      assert (assert (Task.succeed 123) (isIntBetween (Task.succeed 6) (Task.succeed 5))) (failsWith [
        ("Error", "6 is greater than 5"),
        ("Lower", "6"),
        ("Upper", "5"),
        ("Actual", "123")
      ])
    ),

    test "isIntBetween: succeeds if the lower value, actual value and upper value are all the same" (
      assert (Task.succeed 999) (isIntBetween (Task.succeed 999) (Task.succeed 999))
    )
  ]
