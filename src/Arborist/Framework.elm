module Arborist.Framework exposing (
    Test,
    Tests,
    Name,
    TestResult,
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
@docs run, TestResult
-}

import Html
import Html.App exposing (program)
import List
import Task exposing (Task)

import Arborist.Assertions
import Arborist.Matchers exposing (Matcher)

{-| A test case, usually constructed with the `test` function. -}
type Test = Test { name : Name, assertion : Assertion }

{-| A list of `Test` cases. -}
type alias Tests = List Test

{-| The name of a test. -}
type alias Name = String

{-| A test result. -}
type alias TestResult = { passed : Bool, name : Name, failureMessages : FailureMessages }

type alias Assertion = Arborist.Assertions.Assertion
type alias FailureMessage = Arborist.Assertions.FailureMessage
type alias FailureMessages = Arborist.Assertions.FailureMessages

{-| Runs test cases in parallel, and prints the output to the command line. -}
run : List Test -> (TestResult -> Cmd TestResult) -> Program Never
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

constructTests : List Test -> Cmd TestResult
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

check : Name -> Bool -> FailureMessages -> TestResult
check name testPassed failureMessages =
  if testPassed
    then passed name
    else failed name failureMessages

passed : Name -> TestResult
passed name = { passed = True, name = name, failureMessages = [] }

failed : Name -> FailureMessages -> TestResult
failed name failureMessages = { passed = False, name = name, failureMessages = failureMessages }
