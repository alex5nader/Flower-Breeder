module Page.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Asset.Image as Image
import AssocList as Dict exposing (Dict)
import Dropdown exposing (Msg(..))
import Element exposing (Element, centerX, centerY, clip, column, el, fill, fillPortion, height, maximum, padding, paddingEach, px, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Flower exposing (Flower)
import Flower.Color exposing (FlowerColor(..))
import Flower.Kind exposing (FlowerKind(..))
import Genetics exposing (DominantCount(..), DominantList)
import List.Split
import Maybe.Extra
import Page
import Random exposing (Generator)
import Random.List
import Session exposing (Session)
import TabSwitcher
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


type FlowerTab
    = Manual
    | Shop
    | Island


type BreedingResultDisplayMode
    = ByGenes
    | ByColor


type alias Model =
    { session : Session
    , kindData : Dropdown.Model FlowerKind
    , flowerTabA : TabSwitcher.Model FlowerTab
    , flowerTabB : TabSwitcher.Model FlowerTab
    , shopDropdownModelA : Dropdown.Model Flower
    , shopDropdownModelB : Dropdown.Model Flower
    , islandDropdownModelA : Dropdown.Model Flower
    , islandDropdownModelB : Dropdown.Model Flower
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
      , kindData = Dropdown.init Rose
      , flowerTabA = TabSwitcher.init Manual
      , flowerTabB = TabSwitcher.init Manual
      , shopDropdownModelA = Dropdown.init (Flower.getSeedFlower Rose Red |> Maybe.withDefault (Flower Rose [ Zero, Zero, Zero, Zero ]))
      , shopDropdownModelB = Dropdown.init (Flower.getSeedFlower Rose Red |> Maybe.withDefault (Flower Rose [ Zero, Zero, Zero, Zero ]))
      , islandDropdownModelA = Dropdown.init (Flower.getIslandFlower Rose Pink |> Maybe.withDefault (Flower Rose [ Zero, Zero, Zero, Zero ]))
      , islandDropdownModelB = Dropdown.init (Flower.getIslandFlower Rose Pink |> Maybe.withDefault (Flower Rose [ Zero, Zero, Zero, Zero ]))
      , genesA = Dict.fromList (List.map toPair Flower.Kind.allKinds)
      , genesB = Dict.fromList (List.map toPair Flower.Kind.allKinds)
      , colorsToUse = Dict.empty
      , breedingResultDisplayMode = ByGenes
      }
    , Random.generate GotRandom (flowerKindGenerator Flower.Kind.allKinds)
    )


type Msg
    = KindDropdownMsg (Dropdown.Msg FlowerKind)
    | FlowerTabMsgA (TabSwitcher.Msg FlowerTab)
    | FlowerTabMsgB (TabSwitcher.Msg FlowerTab)
    | ShopDropdownMsgA (Dropdown.Msg Flower)
    | ShopDropdownMsgB (Dropdown.Msg Flower)
    | IslandDropdownMsgA (Dropdown.Msg Flower)
    | IslandDropdownMsgB (Dropdown.Msg Flower)
    | SetGenesA FlowerKind DominantList
    | SetGenesB FlowerKind DominantList
    | SetBreedingResultDisplayMode BreedingResultDisplayMode
    | GotRandom (Dict FlowerKind (Maybe FlowerColor))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        KindDropdownMsg subMsg ->
            ( { model | kindData = Dropdown.update subMsg model.kindData }
            , Cmd.none
            )

        FlowerTabMsgA subMsg ->
            ( { model | flowerTabA = TabSwitcher.update subMsg model.flowerTabA }
            , Cmd.none
            )

        FlowerTabMsgB subMsg ->
            ( { model | flowerTabB = TabSwitcher.update subMsg model.flowerTabB }
            , Cmd.none
            )

        ShopDropdownMsgA subMsg ->
            ( case subMsg of
                SetSelected flower ->
                    { model
                        | shopDropdownModelA = Dropdown.update subMsg model.shopDropdownModelA
                        , genesA = Dict.insert flower.kind flower.genes model.genesA
                    }

                _ ->
                    { model | shopDropdownModelA = Dropdown.update subMsg model.shopDropdownModelA }
            , Cmd.none
            )

        ShopDropdownMsgB subMsg ->
            ( case subMsg of
                SetSelected flower ->
                    { model
                        | shopDropdownModelB = Dropdown.update subMsg model.shopDropdownModelB
                        , genesB = Dict.insert flower.kind flower.genes model.genesB
                    }

                _ ->
                    { model | shopDropdownModelB = Dropdown.update subMsg model.shopDropdownModelB }
            , Cmd.none
            )

        IslandDropdownMsgA subMsg ->
            ( case subMsg of
                SetSelected flower ->
                    { model
                        | islandDropdownModelA = Dropdown.update subMsg model.islandDropdownModelA
                        , genesA = Dict.insert flower.kind flower.genes model.genesA
                    }

                _ ->
                    { model | islandDropdownModelA = Dropdown.update subMsg model.islandDropdownModelA }
            , Cmd.none
            )

        IslandDropdownMsgB subMsg ->
            ( case subMsg of
                SetSelected flower ->
                    { model
                        | islandDropdownModelB = Dropdown.update subMsg model.islandDropdownModelB
                        , genesB = Dict.insert flower.kind flower.genes model.genesB
                    }

                _ ->
                    { model | islandDropdownModelB = Dropdown.update subMsg model.islandDropdownModelB }
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
                listWith : Int -> a -> List a -> List a
                listWith pos item list =
                    List.take pos list ++ [ item ] ++ List.drop (pos + 1) list

                viewOption : Int -> DominantCount -> DominantCount -> Element Msg
                viewOption i actual label =
                    let
                        attrs =
                            (if actual == label then
                                [ Font.color (Theme.backgroundColor theme), Background.color (Theme.lineColor theme) ]

                             else
                                [ Background.color (Theme.backgroundColor theme) ]
                            )
                                ++ [ paddingEach { top = 5, left = 5, right = 5, bottom = 0 }, width (fillPortion 1), height (fillPortion 1) ]
                    in
                    el [ clip, width (fillPortion 1) ] (button attrs { onPress = Just (setGenes (listWith i label genes)), label = text (Genetics.toString label) })

                viewColumn : Int -> DominantCount -> Element Msg
                viewColumn i actual =
                    row [ spacing 10 ]
                        [ el [ Font.center ] (text ("Gene " ++ String.fromInt (i + 1)))
                        , row [ width fill, height fill, clip, Border.width 1, Border.rounded 5, Background.color (Theme.lineColor theme), spacing 1 ] (List.map (viewOption i actual) [ Zero, One, Two ])
                        ]
            in
            column [ spacing 5 ] (List.indexedMap viewColumn genes)

        viewGenePicker flower =
            column []
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


viewKind : Element msg -> FlowerKind -> FlowerColor -> Element msg
viewKind label kind color =
    row [ spacing 5, paddingEach { top = 0, left = 0, bottom = 0, right = 5 } ]
        [ Image.fromFlowerKindAndColor kind color
            |> Image.toElement [ height (maximum 36 fill), centerY ] ""
        , el [ Font.center ] label
        ]


viewFlowerInput :
    Theme
    -> (FlowerKind -> DominantList -> Msg)
    -> Maybe Flower
    -> (TabSwitcher.Msg FlowerTab -> Msg)
    -> TabSwitcher.Model FlowerTab
    -> FlowerKind
    -> (Dropdown.Msg Flower -> Msg)
    -> Dropdown.Model Flower
    -> (Dropdown.Msg Flower -> Msg)
    -> Dropdown.Model Flower
    -> Element Msg
viewFlowerInput theme setGenesMsg maybeSelectedFlower tabSwitcherToMsg tabSwitcherModel kind shopToMsg shopModel islandToMsg islandModel =
    let
        renderOption color =
            let
                label =
                    text (Flower.Color.toString color ++ " " ++ Flower.Kind.toString kind)
            in
            viewKind label kind color

        toPair flower =
            ( flower
            , Flower.getColor flower
                |> Maybe.map renderOption
                |> Maybe.withDefault Element.none
            )

        shopOptions =
            Flower.getSeedColors kind
                |> List.filterMap (Flower.getSeedFlower kind >> Maybe.map toPair)
                |> Dict.fromList

        islandOptions =
            Flower.getIslandColors kind
                |> List.filterMap (Flower.getIslandFlower kind >> Maybe.map toPair)
                |> Dict.fromList

        tabContentAttrs =
            [ padding 30, spacing 10, width fill, height (px 240) ]
    in
    TabSwitcher.view
        theme
        [ width (px 400) ]
        (Dict.fromList
            [ ( Manual
              , { label = text "Manual"
                , content = el tabContentAttrs (maybeViewGenePicker theme setGenesMsg maybeSelectedFlower)
                }
              )
            , ( Shop
              , { label = text "Shop Seeds"
                , content = el tabContentAttrs (el [ centerX, centerY ] (Dropdown.view theme shopOptions shopToMsg shopModel))
                }
              )
            , ( Island
              , { label = text "Island Flowers"
                , content = el tabContentAttrs (el [ centerX, centerY ] (Dropdown.view theme islandOptions islandToMsg islandModel))
                }
              )
            ]
        )
        tabSwitcherToMsg
        tabSwitcherModel


view : Theme -> Model -> Page.Data Msg
view theme model =
    let
        kindPair kind =
            ( kind
            , Dict.get kind model.colorsToUse
                |> Maybe.Extra.join
                |> Maybe.map (viewKind (text (Flower.Kind.toString kind)) kind)
                |> Maybe.withDefault Element.none
            )

        maybeFlower genesDict =
            case Dict.get model.kindData.selected genesDict of
                Just genes ->
                    Just (Flower model.kindData.selected genes)

                _ ->
                    Nothing

        maybeFlowerA =
            maybeFlower model.genesA

        maybeFlowerB =
            maybeFlower model.genesB

        dropdownOptions =
            Dict.fromList (List.reverse (List.map kindPair Flower.Kind.allKinds))
    in
    { title = "Breeder"
    , content =
        el [ centerX, centerY, spacing 30, width fill, height fill, paddingEach { top = 30, left = 0, bottom = 0, right = 0 } ] <|
            column [ width fill, height fill, centerX, spacing 15 ]
                [ row [ centerX, spacing 15 ]
                    [ el [] (text "Select a flower")
                    , Dropdown.view theme dropdownOptions KindDropdownMsg model.kindData
                    ]
                , row [ centerX, spacing 45 ]
                    [ viewFlowerInput
                        theme
                        SetGenesA
                        maybeFlowerA
                        FlowerTabMsgA
                        model.flowerTabA
                        model.kindData.selected
                        ShopDropdownMsgA
                        model.shopDropdownModelA
                        IslandDropdownMsgA
                        model.islandDropdownModelA
                    , text "bred with a "
                    , viewFlowerInput
                        theme
                        SetGenesB
                        maybeFlowerB
                        FlowerTabMsgB
                        model.flowerTabB
                        model.kindData.selected
                        ShopDropdownMsgB
                        model.shopDropdownModelB
                        IslandDropdownMsgB
                        model.islandDropdownModelB
                    ]
                , el [ centerX ] (text "will produce")
                , maybeViewBreedingResults theme maybeFlowerA maybeFlowerB
                ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
