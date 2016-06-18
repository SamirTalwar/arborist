module Arborist.Framework exposing (
    Test,
    Tests,
    Name,
    run,
    test,
    assert
  )

{-| Arborist is a test framework for asynchronous code.

It is intended for use mostly with Tasks. Tests are defined as assertions on
tasks, which are executed in parallel and reported on the command line.

# Declaring tests
@docs Test, Tests, Name, test

# Assertions
@docs assert

# Running tests
@docs run
-}

import Html
import Html.App exposing (program)
import List
import String
import Task exposing (Task)

import Arborist.Assertions
import Arborist.Matchers exposing (Matcher)

{-| The name of a test. -}
type alias Name = String

{-| A test case, usually constructed with the `test` function. -}
type Test = Test { name : Name, assertion : Assertion }

{-| A list of `Test` cases. -}
type alias Tests = List Test

type alias Assertion = Arborist.Assertions.Assertion
type alias FailureMessage = Arborist.Assertions.FailureMessage
type alias FailureMessages = Arborist.Assertions.FailureMessages

{-| Runs test cases in parallel, and prints the output to the command line. -}
run : List Test -> (String -> Cmd String) -> Program Never
run tests output =
  program {
    init = ((), constructTests tests),
    update = \message model -> ((), output message),
    view = \model -> Html.div [] [],
    subscriptions = always Sub.none
  }

{-| Defines a test case.

    test "One plus one is most definitely two" (
      assert (Task.succeed (1 + 1)) (equals (Task.succeed 2))
    )
-}
test : Name -> Assertion -> Test
test name assertion =
  Test { name = name, assertion = assertion }

constructTests : List Test -> Cmd String
constructTests tests =
  tests
    |> List.reverse
    |> List.map (\(Test { name, assertion }) ->
      Task.perform (failed name) (uncurry (check name)) assertion)
    |> Cmd.batch

{-| `assert` runs a matcher against a value. All values are generally wrapped in tasks.

    let
      a = Task.succeed 7
      b = Task.succeed 3
      c = Task.map2 (+) a b
    in
      assert c (equals (Task.succeed 10))
-}
assert : Task a b -> Matcher a b -> Assertion
assert = Arborist.Assertions.assert

check : Name -> Bool -> FailureMessages -> String
check name testPassed failureMessages =
  if testPassed
    then passed name
    else failed name failureMessages

passed : Name -> String
passed name = green (name ++ " PASSED")

failed : Name -> FailureMessages -> String
failed name failureMessages =
  failureMessages
    |> List.map (\(key, value) -> "\n  " ++ key ++ ":\n  " ++ value)
    |> String.join ""
    |> (\messages -> name ++ " FAILED" ++ messages)
    |> red

green : String -> String
green string = "\x1b[32m" ++ string ++ reset

red : String -> String
red string = "\x1b[31m" ++ string ++ reset

reset : String
reset = "\x1b[0m"
