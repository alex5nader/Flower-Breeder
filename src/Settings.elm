module Settings exposing (Settings, decoder, default, toJson)

import Flower.Kind exposing (FlowerKind(..))
import Genetics exposing (DominantCount(..), DominantList)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Theme exposing (Theme(..))


type alias Settings =
    { theme : Theme
    }


default : Settings
default =
    { theme = Nature
    }


toJson : Settings -> Value
toJson settings =
    Encode.object
        [ ( "theme", Theme.toJson settings.theme ) ]


decoder : Decoder Settings
decoder =
    Decode.map Settings
        (Decode.field "theme" Theme.decoder)
