module WindowSize exposing (WindowSize, decoder)

import Json.Decode as Decode exposing (Decoder)


type alias WindowSize =
    { width : Int, height : Int }


decoder : Decoder WindowSize
decoder =
    Decode.map2
        WindowSize
        (Decode.field "width" Decode.int)
        (Decode.field "height" Decode.int)
