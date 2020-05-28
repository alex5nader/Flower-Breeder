module Theme exposing (Theme(..), backgroundColor, decoder, lineColor)

import Element exposing (Attribute, Color, rgb255)
import Json.Decode as Decode exposing (Decoder)


type Theme
    = Nature
    | Dark
    | Light


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
