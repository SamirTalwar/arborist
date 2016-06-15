module Main exposing (main)

import Arborist.Framework exposing (..)
import Html
import Html.App exposing (program)

import FailureTest
import SynchronousTest

tests : List Test
tests =
  List.concat [
    FailureTest.tests,
    SynchronousTest.tests
  ]

main : Program Never
main =
  program {
    init = ((), run tests),
    update = \message model -> (model, Cmd.none),
    view = \model -> Html.div [] [],
    subscriptions = always Sub.none
  }
