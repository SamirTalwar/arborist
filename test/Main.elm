port module Main exposing (main)

import Arborist.Framework exposing (..)

import AsynchronousTest
import BetweenTest
import FailureTest
import SynchronousTest

tests : List Test
tests =
  List.concat [
    SynchronousTest.tests,
    AsynchronousTest.tests,
    FailureTest.tests,
    BetweenTest.tests
  ]

port output : String -> Cmd message

main : Program Never
main = run tests output
