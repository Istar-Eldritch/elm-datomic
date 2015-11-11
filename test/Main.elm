-- Example.elm
import String
import Graphics.Element exposing (Element, show)

import ElmTest.Test exposing (test, Test, suite)
import ElmTest.Run as R
import ElmTest.Assertion exposing (assert, assertEqual)
import ElmTest.Runner.Console exposing (runDisplay)
import Console exposing (..)
import Task


tests : Test
tests =
    suite "A Test Suite"
        [ test "Addition" (assertEqual (3 + 7) 10)
        , test "String.left" (assertEqual "a" (String.left 1 "abcdefg"))
        , test "This test should fail" (assert True)
        ]

console : IO ()
console = runDisplay tests


port runner : Signal (Task.Task x ())
port runner = Console.run console
