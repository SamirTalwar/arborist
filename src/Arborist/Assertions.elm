module Arborist.Assertions exposing (..)

import Task exposing (Task)

type alias FailureMessage = (String, String)

type alias FailureMessages = List FailureMessage

type alias Assertion = Task FailureMessages (Bool, FailureMessages)

assert : Task a b -> (Task a b -> Assertion) -> Assertion
assert actual matcher = matcher actual
