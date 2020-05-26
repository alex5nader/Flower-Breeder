module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Asset.Image as Image
import AssocList as Dict exposing (Dict)
import Dropdown
import Element exposing (Element, centerX, centerY, clip, column, el, fill, fillPortion, height, maximum, padding, paddingEach, paddingXY, px, rgb, row, scrollbarY, spacing, text, width, wrappedRow)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Flower exposing (Flower)
import Flower.Color exposing (FlowerColor)
import Flower.Kind exposing (FlowerKind(..))
import Genetics exposing (DominantCount(..), DominantList)
import List.Split
import Maybe.Extra
import Page
import Random exposing (Generator)
import Random.List
import Session exposing (Session)
import Theme exposing (Theme)


flowerKindGenerator : List FlowerKind -> Generator (Dict FlowerKind (Maybe FlowerColor))
flowerKindGenerator kinds =
    let
        toPair kind =
            Random.map2 Tuple.pair (Random.constant kind) (Random.map Tuple.first (Random.List.choose (Flower.getColors kind)))

        addTo : Generator (List ( FlowerKind, Maybe FlowerColor )) -> ( FlowerKind, Maybe FlowerColor ) -> Generator (List ( FlowerKind, Maybe FlowerColor ))
        addTo list tuple =
            Random.andThen ((::) tuple >> Random.constant) list

        folder : FlowerKind -> Generator (List ( FlowerKind, Maybe FlowerColor )) -> Generator (List ( FlowerKind, Maybe FlowerColor ))
        folder item list =
            toPair item
                |> Random.andThen (addTo list)
    in
    List.foldl folder (Random.constant []) kinds
        |> Random.map Dict.fromList


type BreedingResultDisplayMode
    = ByGenes
    | ByColor


type alias Model =
    { session : Session
    , maybeKind : Maybe FlowerKind
    , kindDropdownVisible : Bool
    , genesA : Dict FlowerKind DominantList
    , genesB : Dict FlowerKind DominantList
    , colorsToUse : Dict FlowerKind (Maybe FlowerColor)
    , breedingResultDisplayMode : BreedingResultDisplayMode
    }


toSession : Model -> Session
toSession model =
    model.session


init : Session -> ( Model, Cmd Msg )
init session =
    let
        toPair kind =
            ( kind, List.repeat (Flower.getGeneCount kind) One )
    in
    ( { session = session
      , maybeKind = Just Rose
      , kindDropdownVisible = False
      , genesA = Dict.fromList (List.map toPair Flower.Kind.allKinds)
      , genesB = Dict.fromList (List.map toPair Flower.Kind.allKinds)
      , colorsToUse = Dict.empty
      , breedingResultDisplayMode = ByGenes
      }
    , Random.generate GotRandom (flowerKindGenerator Flower.Kind.allKinds)
    )


type Msg
    = SetKind String
    | SetKindDropdownVisibility Bool
    | SetGenesA FlowerKind DominantList
    | SetGenesB FlowerKind DominantList
    | SetBreedingResultDisplayMode BreedingResultDisplayMode
    | GotRandom (Dict FlowerKind (Maybe FlowerColor))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetKind kindStr ->
            let
                maybeKind =
                    Flower.Kind.fromString kindStr
            in
            ( { model
                | maybeKind = maybeKind
                , kindDropdownVisible = False
              }
            , Cmd.none
            )

        SetKindDropdownVisibility value ->
            ( { model | kindDropdownVisible = value }
            , Cmd.none
            )

        SetGenesA kind genes ->
            ( { model
                | genesA = Dict.insert kind genes model.genesA
              }
            , Cmd.none
            )

        SetGenesB kind genes ->
            ( { model
                | genesB = Dict.insert kind genes model.genesB
              }
            , Cmd.none
            )

        SetBreedingResultDisplayMode mode ->
            ( { model | breedingResultDisplayMode = mode }
            , Cmd.none
            )

        GotRandom random ->
            ( { model | colorsToUse = random }
            , Cmd.none
            )


maybeViewGenePicker : Theme -> (FlowerKind -> DominantList -> Msg) -> Maybe Flower -> Element Msg
maybeViewGenePicker theme setGenesToKind maybeFlower =
    let
        viewGeneSelect : (DominantList -> Msg) -> DominantList -> Element Msg
        viewGeneSelect setGenes genes =
            let
                listWith : String -> Int -> a -> List a -> List a
                listWith label pos item list =
                    Debug.log ("just finished" ++ label) (List.take pos list ++ [ item ] ++ List.drop (pos + 1) list)

                viewOption : Int -> DominantCount -> DominantCount -> Element Msg
                viewOption i actual label =
                    let
                        attrs =
                            (if actual == label then
                                [ Font.color (Theme.backgroundColor theme), Background.color (Theme.lineColor theme) ]

                             else
                                []
                            )
                                ++ [ paddingEach { top = 5, left = 5, right = 5, bottom = 0 }, width (fillPortion 1), height (fillPortion 1) ]
                    in
                    el [ clip, width (fillPortion 1) ] (button attrs { onPress = Just (setGenes (listWith (String.fromInt i) i label genes)), label = text (Genetics.toString label) })

                viewColumn : Int -> DominantCount -> Element Msg
                viewColumn i actual =
                    row [ spacing 10 ]
                        [ el [ Font.center ] (text ("Gene " ++ String.fromInt (i + 1)))
                        , row [ width fill, height fill, clip, Border.width 1, Border.rounded 5 ] (List.map (viewOption i actual) [ Zero, One, Two ])
                        ]
            in
            column [ spacing 5 ] (List.indexedMap viewColumn genes)

        viewGenePicker flower =
            column [ padding 30, spacing 10 ]
                [ el [ centerX ]
                    (Flower.toFullName flower
                        |> Maybe.map text
                        |> Maybe.withDefault Element.none
                    )
                , row [ spacing 20 ]
                    [ Image.fromFlower flower
                        |> Maybe.map (Image.toElement [ height (fillPortion 2), Border.rounded 10, Border.width 1 ] "")
                        |> Maybe.withDefault Element.none
                    , viewGeneSelect (setGenesToKind flower.kind) flower.genes
                    ]
                ]
    in
    maybeFlower |> Maybe.map viewGenePicker |> Maybe.withDefault Element.none


maybeViewBreedingResults : Theme -> Maybe Flower -> Maybe Flower -> Element msg
maybeViewBreedingResults theme maybeFlowerA maybeFlowerB =
    let
        viewOffspring { weight, flower } =
            el [ width (fillPortion 1) ] <|
                row [ width fill, spacing 5, centerX, padding 15, Border.rounded 15, Background.color (Theme.lineColor theme), Font.color (Theme.backgroundColor theme) ]
                    [ el [ Font.size 24, centerX ] (text (String.fromFloat (weight * 100) ++ "%"))
                    , Image.fromFlower flower
                        |> Maybe.map (Image.toElement [ centerX, height (px 48) ] "")
                        |> Maybe.withDefault Element.none
                    , Flower.toFullName flower
                        |> Maybe.map (el [ centerX ] << text)
                        |> Maybe.withDefault Element.none
                    ]

        viewOffspringRow offsprings =
            row [ centerX, width fill, height (fillPortion 1), spacing 50 ]
                (List.map viewOffspring offsprings)

        viewBreedingResults ( flowerA, flowerB ) =
            el [ paddingEach { top = 0, left = 100, bottom = 25, right = 100 }, Border.rounded 25, width fill, height fill ]
                (column [ centerX, spacing 15, width fill, height fill ]
                    (Flower.breed flowerA flowerB
                        |> Result.map (List.Split.chunksOfLeft 4)
                        |> Result.map (List.map viewOffspringRow)
                        |> Result.withDefault []
                    )
                )
    in
    Maybe.map2 Tuple.pair maybeFlowerA maybeFlowerB
        |> Maybe.map viewBreedingResults
        |> Maybe.withDefault Element.none


viewKind : Dict FlowerKind (Maybe FlowerColor) -> FlowerKind -> Element Msg
viewKind colorsToUse kind =
    row [ spacing 5, paddingEach { top = 0, left = 0, bottom = 0, right = 5 } ]
        [ Dict.get kind colorsToUse
            |> Maybe.Extra.join
            |> Maybe.map (Image.fromFlowerKindAndColor kind)
            |> Maybe.map (Image.toElement [ height (maximum 36 fill), centerY ] "")
            |> Maybe.withDefault Element.none
        , el [ Font.center ] (text (Flower.Kind.toString kind))
        ]


view : Theme -> Model -> Page.Data Msg
view theme model =
    let
        kindFieldLabel =
            model.maybeKind
                |> Maybe.map (viewKind model.colorsToUse)
                |> Maybe.withDefault Element.none

        kindFieldValue =
            model.maybeKind
                |> Maybe.map Flower.Kind.toString
                |> Maybe.withDefault ""

        kindPair kind =
            ( Flower.Kind.toString kind
            , viewKind model.colorsToUse kind
            )

        maybeFlower genesDict =
            case model.maybeKind of
                Just kind ->
                    case Dict.get kind genesDict of
                        Just genes ->
                            Just (Flower kind genes)

                        _ ->
                            Nothing

                _ ->
                    Nothing

        maybeFlowerA =
            maybeFlower model.genesA

        maybeFlowerB =
            maybeFlower model.genesB

        dropdownOptions =
            List.map kindPair Flower.Kind.allKinds
    in
    { title = "Breeder"
    , content =
        el [ centerX, centerY, spacing 30, width fill, height fill, paddingEach { top = 30, left = 0, bottom = 0, right = 0 } ] <|
            column [ width fill, height fill, centerX, spacing 15 ]
                [ row [ centerX, spacing 15 ]
                    [ el [] (text "Select a flower")
                    , Dropdown.view theme SetKindDropdownVisibility SetKind model.kindDropdownVisible kindFieldValue kindFieldLabel dropdownOptions
                    ]
                , row [ centerX, spacing 45 ]
                    [ maybeViewGenePicker theme SetGenesA maybeFlowerA
                    , text "bred with a "
                    , maybeViewGenePicker theme SetGenesB maybeFlowerB
                    ]
                , el [ centerX ] (text "will produce")
                , maybeViewBreedingResults theme maybeFlowerA maybeFlowerB
                ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
