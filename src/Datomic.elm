module Datomic (Connection, toUri) where

{-| This module is intended to provide the necessary tools to work with the
datomic rest interface.

# Models
@docs Connection

# Helpers
@docs toUri
-}

{-| A `Connection` represents the configuration neccessary to stablish a
connection with the datomic rest api.
-}
type alias Connection =
  { alias: String
  , server: String
  , port': Int
  }

{-| Converts a `Connection` to a URI String
-}
toUri: Connection -> String
toUri conn = conn.alias ++ " " ++ conn.server ++ ":" ++ toString conn.port'
