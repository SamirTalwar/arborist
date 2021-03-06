module Arborist.Framework exposing (
    Test (..),
    Tests,
    Name,
    test,
    assert,
    pass,
    fail,
    failWith
  )

{-| Arborist is a test framework for asynchronous code.

It is intended for use mostly with Tasks. Tests are defined as assertions on
tasks, which are executed in parallel and reported on the command line.

# Declaring tests
@docs Test, Tests, Name, test

# Assertions
@docs assert, pass, fail, failWith
-}

import Task exposing (Task)

import Arborist.Assertions exposing (Assertion)
import Arborist.Matchers exposing (Matcher)

{-| A test case, usually constructed with the `test` function. -}
type Test = Test Name Assertion

{-| A list of `Test` cases. -}
type alias Tests = List Test

{-| The name of a test. -}
type alias Name = String

{-| Defines a test case.

    test "One plus one is most definitely two" (
      assert (Task.succeed (1 + 1)) (equals (Task.succeed 2))
    )
-}
test : Name -> Assertion -> Test
test = Test

{-| `assert` runs a matcher against a value. All values are generally wrapped in tasks.

    let
      a = Task.succeed 7
      b = Task.succeed 3
      c = Task.map2 (+) a b
    in
      assert c (equals (Task.succeed 10))

This function is re-exported from `Arborist.Assertions` for your convenience.
-}
assert : Task a b -> Matcher a b -> Assertion
assert = Arborist.Assertions.assert

{-| `pass` always passes.

This function is re-exported from `Arborist.Assertions` for your convenience.
-}
pass : Assertion
pass = Arborist.Assertions.pass

{-| `fail` forces the test to fail.

This function is re-exported from `Arborist.Assertions` for your convenience.
-}
fail : Assertion
fail = Arborist.Assertions.fail

{-| `failWith` forces the test to fail with a reason.

This function is re-exported from `Arborist.Assertions` for your convenience.
-}
failWith : String -> Assertion
failWith = Arborist.Assertions.failWith
