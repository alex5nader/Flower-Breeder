module Genetics exposing
    ( DominantCount(..)
    , DominantList
    , Gene(..)
    , breed
    , toCombinations
    , toString
    )

import List
import List.Extra exposing (cartesianProduct)


type Gene
    = Dominant
    | Recessive


type DominantCount
    = Zero
    | One
    | Two


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
