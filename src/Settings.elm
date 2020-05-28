module Settings exposing (Settings, decoder, default)

import Json.Decode as Decode exposing (Decoder)
import Theme exposing (Theme(..))


type alias Settings =
    { theme : Theme
    }


default : Settings
default =
    { theme = Nature
    }


decoder : Decoder Settings
decoder =
    Decode.map Settings
        (Decode.field "theme" Theme.decoder)
