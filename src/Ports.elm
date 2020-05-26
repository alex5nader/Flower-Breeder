port module Ports exposing (onStorageChange, saveToLocalStorage)

import Json.Decode exposing (Value)


port saveToLocalStorage : ( String, Value ) -> Cmd msg


port onStorageChange : (( String, Value ) -> msg) -> Sub msg
