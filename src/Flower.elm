module Flower exposing
    ( BreedError(..)
    , Flower
    , Offspring
    , breed
    , getColor
    , getColors
    , getGeneCount
    , getIslandColors
    , getIslandFlower
    , getSeedColors
    , getSeedFlower
    , toFullName
    , toNameWithGenes
    )

import AssocList as Dict exposing (Dict)
import Flower.Color exposing (FlowerColor(..))
import Flower.Kind exposing (FlowerKind(..))
import Genetics exposing (DominantCount(..), DominantList)


type alias Flower =
    { kind : FlowerKind, genes : DominantList }


type BreedError
    = DifferentSpecies


breedRaw : Flower -> Flower -> Result BreedError (List Flower)
breedRaw a b =
    if a.kind == b.kind then
        Ok (List.map (Flower a.kind) (Genetics.breed a.genes b.genes))

    else
        Err DifferentSpecies


type alias Offspring =
    { total : Int, flower : Flower, count : Int }


addCount : Flower -> Dict Flower Int -> Dict Flower Int
addCount flower counts =
    Dict.insert flower (Maybe.withDefault 0 (Dict.get flower counts) + 1) counts


groupByCount : List Flower -> List Offspring
groupByCount flowers =
    Dict.values
        (Dict.map
            (Offspring (List.length flowers))
            (List.foldl addCount Dict.empty flowers)
        )


breed : Flower -> Flower -> Result BreedError (List Offspring)
breed a b =
    Result.map groupByCount (breedRaw a b)


getGeneCount : FlowerKind -> Int
getGeneCount kind =
    case kind of
        Rose ->
            4

        _ ->
            3


toNameWithGenes : Flower -> String
toNameWithGenes flower =
    List.foldr (++) "" (List.map Genetics.toString flower.genes) ++ " " ++ Flower.Kind.toString flower.kind


toFullName : Flower -> Maybe String
toFullName flower =
    let
        formatName color =
            List.foldr (++) "" (List.map Genetics.toString flower.genes) ++ " " ++ Flower.Color.toString color ++ " " ++ Flower.Kind.toString flower.kind
    in
    getColor flower |> Maybe.map formatName


getSeedFlower : FlowerKind -> FlowerColor -> Maybe Flower
getSeedFlower kind color =
    case ( color, kind ) of
        ( White, Rose ) ->
            Just { kind = Rose, genes = [ Zero, Zero, One, Zero ] }

        ( Yellow, Rose ) ->
            Just { kind = Rose, genes = [ Zero, Two, Zero, Zero ] }

        ( Red, Rose ) ->
            Just { kind = Rose, genes = [ Two, Zero, Zero, One ] }

        ( White, Tulip ) ->
            Just { kind = Tulip, genes = [ Zero, Zero, One ] }

        ( Yellow, Tulip ) ->
            Just { kind = Tulip, genes = [ Zero, Two, Zero ] }

        ( Red, Tulip ) ->
            Just { kind = Tulip, genes = [ Two, Zero, One ] }

        ( White, Pansy ) ->
            Just { kind = Pansy, genes = [ Zero, Zero, One ] }

        ( Yellow, Pansy ) ->
            Just { kind = Pansy, genes = [ Zero, Two, Zero ] }

        ( Red, Pansy ) ->
            Just { kind = Pansy, genes = [ Two, Zero, Zero ] }

        ( White, Cosmos ) ->
            Just { kind = Cosmos, genes = [ Zero, Zero, One ] }

        ( Yellow, Cosmos ) ->
            Just { kind = Cosmos, genes = [ Zero, Two, One ] }

        ( Red, Cosmos ) ->
            Just { kind = Cosmos, genes = [ Two, Zero, Zero ] }

        ( White, Lily ) ->
            Just { kind = Lily, genes = [ Zero, Zero, Two ] }

        ( Yellow, Lily ) ->
            Just { kind = Lily, genes = [ Zero, Two, Zero ] }

        ( Red, Lily ) ->
            Just { kind = Lily, genes = [ Two, Zero, One ] }

        ( White, Hyacinth ) ->
            Just { kind = Hyacinth, genes = [ Zero, Zero, One ] }

        ( Yellow, Hyacinth ) ->
            Just { kind = Hyacinth, genes = [ Zero, Two, Zero ] }

        ( Red, Hyacinth ) ->
            Just { kind = Hyacinth, genes = [ Two, Zero, One ] }

        ( White, Windflower ) ->
            Just { kind = Windflower, genes = [ Zero, Zero, One ] }

        ( Orange, Windflower ) ->
            Just { kind = Windflower, genes = [ Zero, Two, Zero ] }

        ( Red, Windflower ) ->
            Just { kind = Windflower, genes = [ Two, Zero, Zero ] }

        ( White, Mum ) ->
            Just { kind = Mum, genes = [ Zero, Zero, One ] }

        ( Yellow, Mum ) ->
            Just { kind = Mum, genes = [ Zero, Two, Zero ] }

        ( Red, Mum ) ->
            Just { kind = Mum, genes = [ Two, Zero, Zero ] }

        _ ->
            Nothing


getIslandFlower : FlowerKind -> FlowerColor -> Maybe Flower
getIslandFlower kind color =
    case ( color, kind ) of
        ( Pink, Rose ) ->
            Just { kind = Rose, genes = [ Two, Zero, Two, Two ] }

        ( Orange, Rose ) ->
            Just { kind = Rose, genes = [ Two, Two, One, One ] }

        ( Pink, Tulip ) ->
            Just { kind = Tulip, genes = [ One, Zero, One ] }

        ( Orange, Tulip ) ->
            Just { kind = Tulip, genes = [ One, Two, Zero ] }

        ( Black, Tulip ) ->
            Just { kind = Tulip, genes = [ Two, One, Zero ] }

        ( Orange, Pansy ) ->
            Just { kind = Pansy, genes = [ Two, Two, One ] }

        ( Blue, Pansy ) ->
            Just { kind = Pansy, genes = [ One, Zero, Two ] }

        ( Pink, Cosmos ) ->
            Just { kind = Cosmos, genes = [ One, One, Two ] }

        ( Orange, Cosmos ) ->
            Just { kind = Cosmos, genes = [ Two, One, One ] }

        ( Pink, Lily ) ->
            Just { kind = Lily, genes = [ Two, One, Two ] }

        ( Orange, Lily ) ->
            Just { kind = Lily, genes = [ Two, Two, One ] }

        ( Black, Lily ) ->
            Just { kind = Lily, genes = [ Two, One, Zero ] }

        ( Pink, Hyacinth ) ->
            Just { kind = Hyacinth, genes = [ One, Zero, One ] }

        ( Orange, Hyacinth ) ->
            Just { kind = Hyacinth, genes = [ One, Two, Zero ] }

        ( Blue, Hyacinth ) ->
            Just { kind = Hyacinth, genes = [ Two, One, Zero ] }

        ( Pink, Windflower ) ->
            Just { kind = Windflower, genes = [ Two, Two, One ] }

        ( Blue, Windflower ) ->
            Just { kind = Windflower, genes = [ One, Zero, Two ] }

        ( Pink, Mum ) ->
            Just { kind = Mum, genes = [ One, One, Two ] }

        ( Purple, Mum ) ->
            Just { kind = Mum, genes = [ Two, One, One ] }

        _ ->
            Nothing


getSeedColors : FlowerKind -> List FlowerColor
getSeedColors kind =
    case kind of
        Windflower ->
            [ White, Orange, Red ]

        _ ->
            [ White, Yellow, Red ]


getIslandColors : FlowerKind -> List FlowerColor
getIslandColors kind =
    case kind of
        Rose ->
            [ Pink, Orange ]

        Tulip ->
            [ Pink, Orange, Black ]

        Pansy ->
            [ Orange, Blue ]

        Cosmos ->
            [ Pink, Orange ]

        Lily ->
            [ Pink, Orange, Black ]

        Hyacinth ->
            [ Pink, Orange, Blue ]

        Windflower ->
            [ Pink, Blue ]

        Mum ->
            [ Pink, Purple ]


getColors : FlowerKind -> List FlowerColor
getColors kind =
    let
        seed =
            getSeedColors kind

        island =
            getIslandColors kind

        other =
            case kind of
                Rose ->
                    [ Purple, Black, Blue, Gold ]

                Tulip ->
                    [ Purple ]

                Pansy ->
                    [ Purple ]

                Cosmos ->
                    [ Black ]

                Hyacinth ->
                    [ Purple ]

                Windflower ->
                    [ Purple ]

                Mum ->
                    [ Green ]

                _ ->
                    []
    in
    seed ++ island ++ other


getColor : Flower -> Maybe FlowerColor
getColor flower =
    case flower.kind of
        Rose ->
            case flower.genes of
                Zero :: Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: Zero :: [ Two ] ->
                    Just White

                Zero :: Zero :: One :: [ Zero ] ->
                    Just White

                Zero :: Zero :: One :: [ One ] ->
                    Just White

                Zero :: Zero :: One :: [ Two ] ->
                    Just White

                Zero :: Zero :: Two :: [ Zero ] ->
                    Just Purple

                Zero :: Zero :: Two :: [ One ] ->
                    Just Purple

                Zero :: Zero :: Two :: [ Two ] ->
                    Just Purple

                Zero :: One :: Zero :: [ Zero ] ->
                    Just Yellow

                Zero :: One :: Zero :: [ One ] ->
                    Just Yellow

                Zero :: One :: Zero :: [ Two ] ->
                    Just Yellow

                Zero :: One :: One :: [ Zero ] ->
                    Just White

                Zero :: One :: One :: [ One ] ->
                    Just White

                Zero :: One :: One :: [ Two ] ->
                    Just White

                Zero :: One :: Two :: [ Zero ] ->
                    Just Purple

                Zero :: One :: Two :: [ One ] ->
                    Just Purple

                Zero :: One :: Two :: [ Two ] ->
                    Just Purple

                Zero :: Two :: Zero :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: Zero :: [ One ] ->
                    Just Yellow

                Zero :: Two :: Zero :: [ Two ] ->
                    Just Yellow

                Zero :: Two :: One :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: One :: [ One ] ->
                    Just Yellow

                Zero :: Two :: One :: [ Two ] ->
                    Just Yellow

                Zero :: Two :: Two :: [ Zero ] ->
                    Just White

                Zero :: Two :: Two :: [ One ] ->
                    Just White

                Zero :: Two :: Two :: [ Two ] ->
                    Just White

                One :: Zero :: Zero :: [ Zero ] ->
                    Just Red

                One :: Zero :: Zero :: [ One ] ->
                    Just Pink

                One :: Zero :: Zero :: [ Two ] ->
                    Just White

                One :: Zero :: One :: [ Zero ] ->
                    Just Red

                One :: Zero :: One :: [ One ] ->
                    Just Pink

                One :: Zero :: One :: [ Two ] ->
                    Just White

                One :: Zero :: Two :: [ Zero ] ->
                    Just Red

                One :: Zero :: Two :: [ One ] ->
                    Just Pink

                One :: Zero :: Two :: [ Two ] ->
                    Just Purple

                One :: One :: Zero :: [ Zero ] ->
                    Just Orange

                One :: One :: Zero :: [ One ] ->
                    Just Yellow

                One :: One :: Zero :: [ Two ] ->
                    Just Yellow

                One :: One :: One :: [ Zero ] ->
                    Just Red

                One :: One :: One :: [ One ] ->
                    Just Pink

                One :: One :: One :: [ Two ] ->
                    Just White

                One :: One :: Two :: [ Zero ] ->
                    Just Red

                One :: One :: Two :: [ One ] ->
                    Just Pink

                One :: One :: Two :: [ Two ] ->
                    Just Purple

                One :: Two :: Zero :: [ Zero ] ->
                    Just Orange

                One :: Two :: Zero :: [ One ] ->
                    Just Yellow

                One :: Two :: Zero :: [ Two ] ->
                    Just Yellow

                One :: Two :: One :: [ Zero ] ->
                    Just Orange

                One :: Two :: One :: [ One ] ->
                    Just Yellow

                One :: Two :: One :: [ Two ] ->
                    Just Yellow

                One :: Two :: Two :: [ Zero ] ->
                    Just Red

                One :: Two :: Two :: [ One ] ->
                    Just Pink

                One :: Two :: Two :: [ Two ] ->
                    Just White

                Two :: Zero :: Zero :: [ Zero ] ->
                    Just Black

                Two :: Zero :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: Zero :: [ Two ] ->
                    Just Pink

                Two :: Zero :: One :: [ Zero ] ->
                    Just Black

                Two :: Zero :: One :: [ One ] ->
                    Just Red

                Two :: Zero :: One :: [ Two ] ->
                    Just Pink

                Two :: Zero :: Two :: [ Zero ] ->
                    Just Black

                Two :: Zero :: Two :: [ One ] ->
                    Just Red

                Two :: Zero :: Two :: [ Two ] ->
                    Just Pink

                Two :: One :: Zero :: [ Zero ] ->
                    Just Orange

                Two :: One :: Zero :: [ One ] ->
                    Just Orange

                Two :: One :: Zero :: [ Two ] ->
                    Just Yellow

                Two :: One :: One :: [ Zero ] ->
                    Just Red

                Two :: One :: One :: [ One ] ->
                    Just Red

                Two :: One :: One :: [ Two ] ->
                    Just White

                Two :: One :: Two :: [ Zero ] ->
                    Just Black

                Two :: One :: Two :: [ One ] ->
                    Just Red

                Two :: One :: Two :: [ Two ] ->
                    Just Purple

                Two :: Two :: Zero :: [ Zero ] ->
                    Just Orange

                Two :: Two :: Zero :: [ One ] ->
                    Just Orange

                Two :: Two :: Zero :: [ Two ] ->
                    Just Yellow

                Two :: Two :: One :: [ Zero ] ->
                    Just Orange

                Two :: Two :: One :: [ One ] ->
                    Just Orange

                Two :: Two :: One :: [ Two ] ->
                    Just Yellow

                Two :: Two :: Two :: [ Zero ] ->
                    Just Blue

                Two :: Two :: Two :: [ One ] ->
                    Just Red

                Two :: Two :: Two :: [ Two ] ->
                    Just White

                _ ->
                    Nothing

        Tulip ->
            case flower.genes of
                Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: [ Two ] ->
                    Just White

                Zero :: One :: [ Zero ] ->
                    Just Yellow

                Zero :: One :: [ One ] ->
                    Just Yellow

                Zero :: One :: [ Two ] ->
                    Just White

                Zero :: Two :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: [ One ] ->
                    Just Yellow

                Zero :: Two :: [ Two ] ->
                    Just Yellow

                One :: Zero :: [ Zero ] ->
                    Just Red

                One :: Zero :: [ One ] ->
                    Just Pink

                One :: Zero :: [ Two ] ->
                    Just White

                One :: One :: [ Zero ] ->
                    Just Orange

                One :: One :: [ One ] ->
                    Just Yellow

                One :: One :: [ Two ] ->
                    Just Yellow

                One :: Two :: [ Zero ] ->
                    Just Orange

                One :: Two :: [ One ] ->
                    Just Yellow

                One :: Two :: [ Two ] ->
                    Just Yellow

                Two :: Zero :: [ Zero ] ->
                    Just Black

                Two :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: [ Two ] ->
                    Just Red

                Two :: One :: [ Zero ] ->
                    Just Black

                Two :: One :: [ One ] ->
                    Just Red

                Two :: One :: [ Two ] ->
                    Just Red

                Two :: Two :: [ Zero ] ->
                    Just Purple

                Two :: Two :: [ One ] ->
                    Just Purple

                Two :: Two :: [ Two ] ->
                    Just Purple

                _ ->
                    Nothing

        Pansy ->
            case flower.genes of
                Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: [ Two ] ->
                    Just Blue

                Zero :: One :: [ Zero ] ->
                    Just Yellow

                Zero :: One :: [ One ] ->
                    Just Yellow

                Zero :: One :: [ Two ] ->
                    Just Blue

                Zero :: Two :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: [ One ] ->
                    Just Yellow

                Zero :: Two :: [ Two ] ->
                    Just Yellow

                One :: Zero :: [ Zero ] ->
                    Just Red

                One :: Zero :: [ One ] ->
                    Just Red

                One :: Zero :: [ Two ] ->
                    Just Blue

                One :: One :: [ Zero ] ->
                    Just Orange

                One :: One :: [ One ] ->
                    Just Orange

                One :: One :: [ Two ] ->
                    Just Orange

                One :: Two :: [ Zero ] ->
                    Just Yellow

                One :: Two :: [ One ] ->
                    Just Yellow

                One :: Two :: [ Two ] ->
                    Just Yellow

                Two :: Zero :: [ Zero ] ->
                    Just Red

                Two :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: [ Two ] ->
                    Just Purple

                Two :: One :: [ Zero ] ->
                    Just Red

                Two :: One :: [ One ] ->
                    Just Red

                Two :: One :: [ Two ] ->
                    Just Purple

                Two :: Two :: [ Zero ] ->
                    Just Orange

                Two :: Two :: [ One ] ->
                    Just Orange

                Two :: Two :: [ Two ] ->
                    Just Purple

                _ ->
                    Nothing

        Cosmos ->
            case flower.genes of
                Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: [ Two ] ->
                    Just White

                Zero :: One :: [ Zero ] ->
                    Just Yellow

                Zero :: One :: [ One ] ->
                    Just Yellow

                Zero :: One :: [ Two ] ->
                    Just White

                Zero :: Two :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: [ One ] ->
                    Just Yellow

                Zero :: Two :: [ Two ] ->
                    Just Yellow

                One :: Zero :: [ Zero ] ->
                    Just Pink

                One :: Zero :: [ One ] ->
                    Just Pink

                One :: Zero :: [ Two ] ->
                    Just Pink

                One :: One :: [ Zero ] ->
                    Just Orange

                One :: One :: [ One ] ->
                    Just Orange

                One :: One :: [ Two ] ->
                    Just Pink

                One :: Two :: [ Zero ] ->
                    Just Orange

                One :: Two :: [ One ] ->
                    Just Orange

                One :: Two :: [ Two ] ->
                    Just Orange

                Two :: Zero :: [ Zero ] ->
                    Just Red

                Two :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: [ Two ] ->
                    Just Red

                Two :: One :: [ Zero ] ->
                    Just Orange

                Two :: One :: [ One ] ->
                    Just Orange

                Two :: One :: [ Two ] ->
                    Just Red

                Two :: Two :: [ Zero ] ->
                    Just Black

                Two :: Two :: [ One ] ->
                    Just Black

                Two :: Two :: [ Two ] ->
                    Just Red

                _ ->
                    Nothing

        Lily ->
            case flower.genes of
                Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: [ Two ] ->
                    Just White

                Zero :: One :: [ Zero ] ->
                    Just Yellow

                Zero :: One :: [ One ] ->
                    Just White

                Zero :: One :: [ Two ] ->
                    Just White

                Zero :: Two :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: [ One ] ->
                    Just Yellow

                Zero :: Two :: [ Two ] ->
                    Just White

                One :: Zero :: [ Zero ] ->
                    Just Red

                One :: Zero :: [ One ] ->
                    Just Pink

                One :: Zero :: [ Two ] ->
                    Just White

                One :: One :: [ Zero ] ->
                    Just Orange

                One :: One :: [ One ] ->
                    Just Yellow

                One :: One :: [ Two ] ->
                    Just Yellow

                One :: Two :: [ Zero ] ->
                    Just Orange

                One :: Two :: [ One ] ->
                    Just Yellow

                One :: Two :: [ Two ] ->
                    Just Yellow

                Two :: Zero :: [ Zero ] ->
                    Just Black

                Two :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: [ Two ] ->
                    Just Pink

                Two :: One :: [ Zero ] ->
                    Just Black

                Two :: One :: [ One ] ->
                    Just Red

                Two :: One :: [ Two ] ->
                    Just Pink

                Two :: Two :: [ Zero ] ->
                    Just Orange

                Two :: Two :: [ One ] ->
                    Just Orange

                Two :: Two :: [ Two ] ->
                    Just White

                _ ->
                    Nothing

        Hyacinth ->
            case flower.genes of
                Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: [ Two ] ->
                    Just Blue

                Zero :: One :: [ Zero ] ->
                    Just Yellow

                Zero :: One :: [ One ] ->
                    Just Yellow

                Zero :: One :: [ Two ] ->
                    Just White

                Zero :: Two :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: [ One ] ->
                    Just Yellow

                Zero :: Two :: [ Two ] ->
                    Just Yellow

                One :: Zero :: [ Zero ] ->
                    Just Red

                One :: Zero :: [ One ] ->
                    Just Pink

                One :: Zero :: [ Two ] ->
                    Just White

                One :: One :: [ Zero ] ->
                    Just Orange

                One :: One :: [ One ] ->
                    Just Yellow

                One :: One :: [ Two ] ->
                    Just Yellow

                One :: Two :: [ Zero ] ->
                    Just Orange

                One :: Two :: [ One ] ->
                    Just Yellow

                One :: Two :: [ Two ] ->
                    Just Yellow

                Two :: Zero :: [ Zero ] ->
                    Just Red

                Two :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: [ Two ] ->
                    Just Red

                Two :: One :: [ Zero ] ->
                    Just Blue

                Two :: One :: [ One ] ->
                    Just Red

                Two :: One :: [ Two ] ->
                    Just Red

                Two :: Two :: [ Zero ] ->
                    Just Purple

                Two :: Two :: [ One ] ->
                    Just Purple

                Two :: Two :: [ Two ] ->
                    Just Purple

                _ ->
                    Nothing

        Windflower ->
            case flower.genes of
                Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: [ Two ] ->
                    Just Blue

                Zero :: One :: [ Zero ] ->
                    Just Orange

                Zero :: One :: [ One ] ->
                    Just Orange

                Zero :: One :: [ Two ] ->
                    Just Blue

                Zero :: Two :: [ Zero ] ->
                    Just Orange

                Zero :: Two :: [ One ] ->
                    Just Orange

                Zero :: Two :: [ Two ] ->
                    Just Orange

                One :: Zero :: [ Zero ] ->
                    Just Red

                One :: Zero :: [ One ] ->
                    Just Red

                One :: Zero :: [ Two ] ->
                    Just Blue

                One :: One :: [ Zero ] ->
                    Just Pink

                One :: One :: [ One ] ->
                    Just Pink

                One :: One :: [ Two ] ->
                    Just Pink

                One :: Two :: [ Zero ] ->
                    Just Orange

                One :: Two :: [ One ] ->
                    Just Orange

                One :: Two :: [ Two ] ->
                    Just Orange

                Two :: Zero :: [ Zero ] ->
                    Just Red

                Two :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: [ Two ] ->
                    Just Purple

                Two :: One :: [ Zero ] ->
                    Just Red

                Two :: One :: [ One ] ->
                    Just Red

                Two :: One :: [ Two ] ->
                    Just Purple

                Two :: Two :: [ Zero ] ->
                    Just Pink

                Two :: Two :: [ One ] ->
                    Just Pink

                Two :: Two :: [ Two ] ->
                    Just Purple

                _ ->
                    Nothing

        Mum ->
            case flower.genes of
                Zero :: Zero :: [ Zero ] ->
                    Just White

                Zero :: Zero :: [ One ] ->
                    Just White

                Zero :: Zero :: [ Two ] ->
                    Just Purple

                Zero :: One :: [ Zero ] ->
                    Just Yellow

                Zero :: One :: [ One ] ->
                    Just Yellow

                Zero :: One :: [ Two ] ->
                    Just White

                Zero :: Two :: [ Zero ] ->
                    Just Yellow

                Zero :: Two :: [ One ] ->
                    Just Yellow

                Zero :: Two :: [ Two ] ->
                    Just Yellow

                One :: Zero :: [ Zero ] ->
                    Just Pink

                One :: Zero :: [ One ] ->
                    Just Pink

                One :: Zero :: [ Two ] ->
                    Just Pink

                One :: One :: [ Zero ] ->
                    Just Yellow

                One :: One :: [ One ] ->
                    Just Red

                One :: One :: [ Two ] ->
                    Just Pink

                One :: Two :: [ Zero ] ->
                    Just Purple

                One :: Two :: [ One ] ->
                    Just Purple

                One :: Two :: [ Two ] ->
                    Just Purple

                Two :: Zero :: [ Zero ] ->
                    Just Red

                Two :: Zero :: [ One ] ->
                    Just Red

                Two :: Zero :: [ Two ] ->
                    Just Red

                Two :: One :: [ Zero ] ->
                    Just Purple

                Two :: One :: [ One ] ->
                    Just Purple

                Two :: One :: [ Two ] ->
                    Just Red

                Two :: Two :: [ Zero ] ->
                    Just Green

                Two :: Two :: [ One ] ->
                    Just Green

                Two :: Two :: [ Two ] ->
                    Just Red

                _ ->
                    Nothing
