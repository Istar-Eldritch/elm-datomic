module Datomic (Connection, DB, uri, storages, databases, createDB, transact, info, datoms, entity, query) where

{-| This module is intended to provide the necessary tools to work with the
datomic rest interface.

# Models
@docs Connection
@docs DB

# Helpers
@docs uri
@docs storages
@docs databases
@docs createDB
@docs transact
@docs info
@docs datoms
@docs entity
@docs query
-}

import Http exposing (..)
import Task exposing (..)
import String
import List


{-| A `Connection` represents the configuration neccessary to stablish a
connection with the datomic rest api.
-}
type alias Connection x =
  { x |
    server: String,
    port': Int
  }


{-| A `DB` represents a database, it can be used with connection
-}
type alias DB =
  { alias: String
  , name: String
  }


root: Connection x -> String
root conn = "http://"
  ++ conn.server
  ++ ":"
  ++ toString conn.port'
  ++ "/"


data: Connection x -> String
data conn = root conn ++ "data/"

{-| Converts a `Connection` to a URI String
-}
uri: Connection DB -> String
uri conn = data conn
  ++ conn.alias
  ++ "/"
  ++ conn.name
  ++ "/"

uri_: Connection DB -> String
uri_ conn = uri conn ++ "-/"


urit: Connection DB -> String -> String
urit conn t = uri conn ++ t ++ "/"

queryPair : (String,String) -> String
queryPair (key,value) =
  uriEncode key ++ "=" ++ uriEncode value


formUrlEncode: List (String, String) -> Body
formUrlEncode args =
  String.join "&" (List.map queryPair args) |> string


{-| Returns a task that abstracts the call to the specified uri -}
dbGET: String -> Task RawError Response
dbGET uri =
  send defaultSettings
    { verb = "GET"
    , headers =
        [ ("Accept", "application/edn") ]
    , url = uri
    , body = empty
    }

dbPOST: String -> Body -> Task RawError Response
dbPOST uri bod =
  send defaultSettings
    { verb = "POST"
    , headers =
        [ ("Accept" , "application/edn")
        , ("Content-Type", "application/x-www-form-urlencoded")
        ]
    , url = uri
    , body = bod
    }


{-| Returns the storages available -}
storages: Connection x -> Task RawError Response
storages conn = dbGET
    <| data conn


{-| Returns the databases available in the storage provided -}
databases: Connection x -> String -> Task RawError Response
databases conn al = dbGET
    <| data conn ++ al ++ "/"


{-| Creates a new database -}
createDB: Connection DB -> Task RawError Response
createDB conn =
  let uri = data conn ++ conn.alias ++ "/"
      body = [ ("db-name", conn.name) ] |> formUrlEncode
  in
    dbPOST uri body


{-| Transaction -}
transact: Connection DB -> String -> Task RawError Response
transact conn dat =
  let url = uri conn
      body = [ ("tx-data", dat) ] |> formUrlEncode
  in dbPOST url body


{-| Returns information of the database -}
info: Connection DB -> String -> Task RawError Response
info conn t =
  let url = uri conn ++ t ++ "/"
  in dbGET url


{-| Returns a set or range of datoms from an index -}
datoms: Connection DB -> String -> List (String, String) -> Task RawError Response
datoms conn t options =
  let query = url (urit conn t ++ "datoms") options
  in dbGET query


{-| Returns all attributes of specified entity. -}
entity: Connection DB -> String -> List (String, String) -> Task RawError Response
entity conn t options =
  let query = url (urit conn t ++ "entity") options
  in dbGET query


{-| Executes a query against one or more databases, returns results. -}
query: Connection DB -> List (String, String) -> Task RawError Response
query conn options =
  let uri = root conn ++ "api/query"
      body = formUrlEncode options
  in dbPOST uri body
