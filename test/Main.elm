-- Example.elm
import String
import Graphics.Element exposing (Element, show)

import ElmTest.Test exposing (test, Test, suite)
import ElmTest.Run as R
import ElmTest.Assertion exposing (assert, assertEqual, Assertion)
import ElmTest.Runner.Console exposing (runDisplay)
-- import Console exposing (..)
import Task exposing (..)
import Datomic exposing (..)
import Http

main: Signal Element
main =
  Signal.map show response.signal


response: Signal.Mailbox String
response =
  Signal.mailbox ""


report: Http.Response -> Task x ()
report msg =
  Signal.send response.address (toString msg.value)


port fetchDB : Task Http.RawError ()
port fetchDB =
  let db = DB "dev" "centola"
      conn = Connection "datomicdb" 8001 db
  in query conn
      [ ("q", "[:find ?e ?v :in $ :where [?e :db/doc ?v]]")
      , ("args", "[{:db/alias \"dev/centola\"}]")
      ]
    `andThen` report
