module Theme exposing (Theme(..), backgroundColor, decoder, lineColor, toJson, toString)

import Element exposing (Attribute, Color, rgb255)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)



-- https://coolors.co/caffb9-66a182-ffffff-000000-323232-dddddd


type Theme
    = Nature -- https://coolors.co/2e4057-66a182-caffb9-aef78e-c0d461
    | Dark
    | Light


toString : Theme -> String
toString theme =
    case theme of
        Nature ->
            "Nature"

        Dark ->
            "Dark"

        Light ->
            "Light"


toJson : Theme -> Value
toJson theme =
    Encode.string (toString theme)


decoder : Decoder Theme
decoder =
    let
        decodeTheme themeString =
            case themeString of
                "Nature" ->
                    Decode.succeed Nature

                "Dark" ->
                    Decode.succeed Dark

                "Light" ->
                    Decode.succeed Light

                _ ->
                    Decode.fail ("Invalid theme: " ++ themeString)
    in
    Decode.string |> Decode.andThen decodeTheme


backgroundColor : Theme -> Color
backgroundColor theme =
    case theme of
        Nature ->
            rgb255 0xCA 0xFF 0xB9

        Dark ->
            rgb255 0x32 0x32 0x32

        Light ->
            rgb255 0xFF 0xFF 0xFF


lineColor : Theme -> Color
lineColor theme =
    case theme of
        Nature ->
            rgb255 0x66 0xA1 0x82

        Dark ->
            rgb255 0xDD 0xDD 0xDD

        Light ->
            rgb255 0x00 0x00 0x00
