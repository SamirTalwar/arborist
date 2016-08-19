module Arborist.Assertions exposing (..)

{-| Provide a mechanism for asserting that a value (wrapped in a task)
successfully matches the behaviour outlined by the matcher.

# Assertions

@docs assert, pass, fail, failWith

# Types

The types provided are generally to be used when constructing your own matchers.

@docs Assertion, FailureMessage, FailureMessages
-}

import Task exposing (Task)

{-| A `FailureMessage` consists of a name and a value to be displayed on failure.  -}
type alias FailureMessage = (String, String)

{-| `FailureMessages` is a list of `FailureMessage` values.  -}
type alias FailureMessages = List FailureMessage

{-| `Assertion` is a task representing either success, failure or error.  -}
type alias Assertion = Task FailureMessages (Bool, FailureMessages)

{-| `assert` runs a matcher against a value. All values are generally wrapped in tasks.

    let
      a = Task.succeed 7
      b = Task.succeed 3
      c = Task.map2 (+) a b
    in
      assert c (equals (Task.succeed 10))
-}
assert : Task a b -> (Task a b -> Assertion) -> Assertion
assert actual matcher = matcher actual

{-| `pass` always passes.
-}
pass : Assertion
pass = Task.succeed (True, [("State", "Pass")])

{-| `fail` forces the test to fail.
-}
fail : Assertion
fail = Task.fail [("State", "Fail")]

{-| `failWith` forces the test to fail with a reason.
-}
failWith : String -> Assertion
failWith message = Task.fail [("State", "Fail"), ("Message", message)]
