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


type FlowerSelectionData
    = Preset Flower
    | Custom Flower


getFlowerSelectionDataKind data =
    case data of
        Preset f ->
            f.kind

        Custom f ->
            f.kind


getFlowerSelectionDataGenes data =
    case data of
        Preset f ->
            f.genes

        Custom f ->
            f.genes


type alias Model =
    { session : Session
    , kindData : Dropdown.Model FlowerKind
    , dropdownModelA : Dropdown.Model FlowerSelectionData
    , dropdownModelB : Dropdown.Model FlowerSelectionData
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
        defaultFlower kind =
            -- can never fail
            Flower kind (List.repeat (Flower.getGeneCount kind) Zero)

        toPair kind =
            ( kind, (defaultFlower kind).genes )
    in
    ( { session = session
      , kindData = Dropdown.init Rose
      , dropdownModelA = Dropdown.init (Preset (defaultFlower Rose))
      , dropdownModelB = Dropdown.init (Preset (defaultFlower Rose))
      , genesA = Dict.fromList (List.map toPair Flower.Kind.allKinds)
      , genesB = Dict.fromList (List.map toPair Flower.Kind.allKinds)
      , colorsToUse = Dict.empty
      , breedingResultDisplayMode = ByGenes
      }
    , Random.generate GotRandom (flowerKindGenerator Flower.Kind.allKinds)
    )


type Msg
    = KindDropdownMsg (Dropdown.Msg FlowerKind)
    | DropdownMsgA (Dropdown.Msg FlowerSelectionData)
    | DropdownMsgB (Dropdown.Msg FlowerSelectionData)
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

        DropdownMsgA subMsg ->
            ( case subMsg of
                SetSelected data ->
                    { model
                        | dropdownModelA = Dropdown.update subMsg model.dropdownModelA
                        , genesA = Dict.insert (getFlowerSelectionDataKind data) (getFlowerSelectionDataGenes data) model.genesA
                    }

                _ ->
                    { model | dropdownModelA = Dropdown.update subMsg model.dropdownModelA }
            , Cmd.none
            )

        DropdownMsgB subMsg ->
            ( case subMsg of
                SetSelected data ->
                    { model
                        | dropdownModelB = Dropdown.update subMsg model.dropdownModelB
                        , genesB = Dict.insert (getFlowerSelectionDataKind data) (getFlowerSelectionDataGenes data) model.genesB
                    }

                _ ->
                    { model | dropdownModelB = Dropdown.update subMsg model.dropdownModelB }
            , Cmd.none
            )

        SetGenesA kind genes ->
            let
                flower =
                    Flower kind genes

                flowerSelectionKind =
                    let
                        color =
                            Flower.getColor flower

                        correspondingIslandGenes =
                            color
                                |> Maybe.andThen (Flower.getIslandFlower kind)
                                |> Maybe.map .genes

                        correspondingSeedGenes =
                            color
                                |> Maybe.andThen (Flower.getSeedFlower kind)
                                |> Maybe.map .genes
                    in
                    if Just genes /= correspondingIslandGenes && Just genes /= correspondingSeedGenes then
                        Custom

                    else
                        Preset
            in
            ( { model
                | genesA = Dict.insert kind genes model.genesA
                , dropdownModelA = Dropdown.update (SetSelected (flowerSelectionKind flower)) model.dropdownModelA
              }
            , Cmd.none
            )

        SetGenesB kind genes ->
            let
                flower =
                    Flower kind genes

                flowerSelectionKind =
                    let
                        color =
                            Flower.getColor flower

                        correspondingIslandGenes =
                            color
                                |> Maybe.andThen (Flower.getIslandFlower kind)
                                |> Maybe.map .genes

                        correspondingSeedGenes =
                            color
                                |> Maybe.andThen (Flower.getSeedFlower kind)
                                |> Maybe.map .genes
                    in
                    if Just genes /= correspondingIslandGenes && Just genes /= correspondingSeedGenes then
                        Custom

                    else
                        Preset
            in
            ( { model
                | genesB = Dict.insert kind genes model.genesB
                , dropdownModelB = Dropdown.update (SetSelected (flowerSelectionKind flower)) model.dropdownModelB
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


maybeViewGenePicker :
    Theme
    -> (FlowerKind -> DominantList -> Msg)
    -> Maybe Flower
    -> (Dropdown.Msg FlowerSelectionData -> Msg)
    -> Dropdown.Model FlowerSelectionData
    -> Element Msg
maybeViewGenePicker theme setGenesToKind maybeSelectedFlower presetToMsg presetModel =
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

        viewGenePicker : Flower -> Element Msg
        viewGenePicker selectedFlower =
            let
                options =
                    let
                        viewPreset color =
                            let
                                label =
                                    text (Flower.Color.toString color ++ " " ++ Flower.Kind.toString selectedFlower.kind)
                            in
                            viewKind label selectedFlower.kind color

                        toPresetPair flower =
                            ( Preset flower
                            , ( Flower.getColor flower
                                    |> Maybe.map viewPreset
                                    |> Maybe.withDefault Element.none
                              , True
                              )
                            )

                        shopOptions =
                            Flower.getSeedColors selectedFlower.kind
                                |> List.filterMap (Flower.getSeedFlower selectedFlower.kind >> Maybe.map toPresetPair)

                        islandOptions =
                            Flower.getIslandColors selectedFlower.kind
                                |> List.filterMap (Flower.getIslandFlower selectedFlower.kind >> Maybe.map toPresetPair)

                        customOption color =
                            ( viewKind (text ("Custom " ++ Flower.Kind.toString selectedFlower.kind)) selectedFlower.kind color, False )

                        maybeCustomOption =
                            Flower.getColor selectedFlower
                                |> Maybe.map customOption
                    in
                    (shopOptions ++ islandOptions)
                        |> (::)
                            ( Custom selectedFlower
                            , maybeCustomOption |> Maybe.withDefault ( Element.none, False )
                            )
                        |> List.reverse
                        |> Dict.fromList
            in
            column [ spacing 15 ]
                [ el [ centerX, centerY, width (px 225) ] (Dropdown.view theme options presetToMsg presetModel)
                , row [ spacing 20 ]
                    [ Image.fromFlower selectedFlower
                        |> Maybe.map (Image.toElement [ height (fillPortion 2) ] "")
                        |> Maybe.withDefault Element.none
                    , viewGeneSelect (setGenesToKind selectedFlower.kind) selectedFlower.genes
                    ]
                ]
    in
    maybeSelectedFlower |> Maybe.map viewGenePicker |> Maybe.withDefault Element.none


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


view : Theme -> Model -> Page.Data Msg
view theme model =
    let
        kindPair kind =
            ( kind
            , ( Dict.get kind model.colorsToUse
                    |> Maybe.Extra.join
                    |> Maybe.map (viewKind (text (Flower.Kind.toString kind)) kind)
                    |> Maybe.withDefault Element.none
              , True
              )
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
            Flower.Kind.allKinds
                |> List.map kindPair
                |> List.reverse
                |> Dict.fromList
    in
    { title = "Breeder"
    , content =
        el [ centerX, centerY, spacing 30, width fill, height fill, paddingEach { top = 30, left = 0, bottom = 0, right = 0 } ] <|
            column [ width fill, height fill, centerX, spacing 30 ]
                [ row [ centerX, spacing 15 ]
                    [ el [] (text "Select a flower")
                    , el [ width (px 146) ] (Dropdown.view theme dropdownOptions KindDropdownMsg model.kindData)
                    ]
                , row [ centerX, spacing 45 ]
                    [ maybeViewGenePicker
                        theme
                        SetGenesA
                        maybeFlowerA
                        DropdownMsgA
                        model.dropdownModelA
                    , text "bred with a "
                    , maybeViewGenePicker
                        theme
                        SetGenesB
                        maybeFlowerB
                        DropdownMsgB
                        model.dropdownModelB
                    ]
                , el [ centerX ] (text "will produce")
                , maybeViewBreedingResults theme maybeFlowerA maybeFlowerB
                ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
