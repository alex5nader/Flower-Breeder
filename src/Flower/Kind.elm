module Flower.Kind exposing
    ( FlowerKind(..)
    , allKinds
    , toString
    )


type FlowerKind
    = Rose
    | Tulip
    | Pansy
    | Cosmos
    | Lily
    | Hyacinth
    | Windflower
    | Mum


allKinds : List FlowerKind
allKinds =
    [ Rose, Tulip, Pansy, Cosmos, Lily, Hyacinth, Windflower, Mum ]


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
