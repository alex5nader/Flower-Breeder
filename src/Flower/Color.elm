module Flower.Color exposing (FlowerColor(..), toString)


type FlowerColor
    = Red
    | Yellow
    | Orange
    | Green
    | Blue
    | Purple
    | Pink
    | Black
    | White
    | Gold


toString : FlowerColor -> String
toString color =
    case color of
        Red ->
            "Red"

        Yellow ->
            "Yellow"

        Orange ->
            "Orange"

        Green ->
            "Green"

        Blue ->
            "Blue"

        Purple ->
            "Purple"

        Pink ->
            "Pink"

        Black ->
            "Black"

        White ->
            "White"

        Gold ->
            "Gold"
