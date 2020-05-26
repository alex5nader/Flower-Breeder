module Genetics exposing
    ( DominantCount(..)
    , DominantList
    , Gene(..)
    , breed
    , dominantCountDecoder
    , toCombinations
    , toInt
    , toString
    )

import Json.Decode as Decode exposing (Decoder)
import List
import List.Extra exposing (cartesianProduct)


type Gene
    = Dominant
    | Recessive


type DominantCount
    = Zero
    | One
    | Two


dominantCountDecoder : Decoder DominantCount
dominantCountDecoder =
    let
        decodeCount countInt =
            case countInt of
                0 ->
                    Decode.succeed Zero

                1 ->
                    Decode.succeed One

                2 ->
                    Decode.succeed Two

                _ ->
                    Decode.fail "Invalid DominantCount"
    in
    Decode.int |> Decode.andThen decodeCount


toString : DominantCount -> String
toString count =
    case count of
        Zero ->
            "0"

        One ->
            "1"

        Two ->
            "2"


type alias DominantList =
    List DominantCount


toGenes : DominantCount -> List Gene
toGenes pair =
    case pair of
        Zero ->
            [ Recessive, Recessive ]

        One ->
            [ Recessive, Dominant ]

        Two ->
            [ Dominant, Dominant ]


toInt : DominantCount -> Int
toInt count =
    case count of
        Zero ->
            0

        One ->
            1

        Two ->
            2


toDominantCount : ( Gene, Gene ) -> DominantCount
toDominantCount genes =
    case genes of
        ( Recessive, Recessive ) ->
            Zero

        ( Recessive, Dominant ) ->
            One

        ( Dominant, Recessive ) ->
            One

        ( Dominant, Dominant ) ->
            Two


toCombinations : DominantList -> List (List Gene)
toCombinations a =
    cartesianProduct (List.map toGenes a)


combine : List Gene -> List Gene -> DominantList
combine a b =
    List.map toDominantCount (List.map2 Tuple.pair a b)


makeRow : List (List Gene) -> List Gene -> List DominantList
makeRow row curCol =
    List.map (combine curCol) row


breed : DominantList -> DominantList -> List DominantList
breed a b =
    List.concatMap (makeRow (toCombinations b)) (toCombinations a)
