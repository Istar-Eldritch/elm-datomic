# elm-datomic
Datomic driver for elm

### Example of usage

```elm
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

```

### TODO
- Add a edn parser so we can work with Native Elm
