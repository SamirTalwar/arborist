module Main exposing (main)

import Arborist.Framework exposing (..)
import Html
import Html.App exposing (program)

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

main : Program Never
main =
  program {
    init = ((), run tests),
    update = \message model -> (model, Cmd.none),
    view = \model -> Html.div [] [],
    subscriptions = always Sub.none
  }
