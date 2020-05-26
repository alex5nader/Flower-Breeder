module Flower.Kind exposing
    ( FlowerKind(..)
    , allKinds
    , decoder
    , fromString
    , toJson
    , toString
    )

import Element exposing (Element, image)
import Json.Decode as Decode exposing (Decoder, Value)
import Json.Encode as Encode



--import GeneKind exposing (GeneKind(..))


type FlowerKind
    = Rose
    | Tulip
    | Pansy
    | Cosmos
    | Lily
    | Hyacinth
    | Windflower
    | Mum


decoder : Decoder FlowerKind
decoder =
    let
        decodeKind kindStr =
            case fromString kindStr of
                Just kind ->
                    Decode.succeed kind

                _ ->
                    Decode.fail "Invalid FlowerKind"
    in
    Decode.string |> Decode.andThen decodeKind


toJson : FlowerKind -> Value
toJson kind =
    Encode.string (toString kind)


allKinds : List FlowerKind
allKinds =
    [ Rose, Tulip, Pansy, Cosmos, Lily, Hyacinth, Windflower, Mum ]



--case kind of
--    Rose ->
--image { description = desc, src = "/" }


toString : FlowerKind -> String
toString kind =
    case kind of
        Rose ->
            "Rose"

        Tulip ->
            "Tulip"

        Pansy ->
            "Pansy"

        Cosmos ->
            "Cosmos"

        Lily ->
            "Lily"

        Hyacinth ->
            "Hyacinth"

        Windflower ->
            "Windflower"

        Mum ->
            "Mum"


fromString : String -> Maybe FlowerKind
fromString string =
    case string of
        "Rose" ->
            Just Rose

        "Tulip" ->
            Just Tulip

        "Pansy" ->
            Just Pansy

        "Cosmos" ->
            Just Cosmos

        "Lily" ->
            Just Lily

        "Hyacinth" ->
            Just Hyacinth

        "Windflower" ->
            Just Windflower

        "Mum" ->
            Just Mum

        _ ->
            Nothing



--geneKinds : FlowerKind -> List GeneKind
--geneKinds kind =
--    case kind of
--        Rose ->
--            [ Red, Yellow, White, Shade ]
--
--        Tulip ->
--            [ Red, Yellow, Shade ]
--
--        Pansy ->
--            [ Red, Yellow, White ]
--
--        Cosmos ->
--            [ Red, Yellow, Shade ]
--
--        Lily ->
--            [ Red, Yellow, Shade ]
--
--        Hyacinth ->
--            [ Red, Yellow, White ]
--
--        Windflower ->
--            [ Red, Orange, White ]
--
--        Mum ->
--            [ Red, Yellow, White ]
