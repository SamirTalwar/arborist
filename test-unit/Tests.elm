module Test.Arborist.Unit exposing (tests)

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
