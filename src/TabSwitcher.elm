module TabSwitcher exposing (Model, Msg, TabData, init, update, view)

import AssocList as Dict exposing (Dict)
import Element exposing (Attribute, Element, clip, column, fill, fillPortion, height, paddingEach, row, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font
import Element.Input exposing (button)
import Theme exposing (Theme)


type alias TabData msg =
    { label : Element msg
    , content : Element msg
    }


type alias Model key =
    { selected : key }


init : key -> Model key
init initialSelected =
    { selected = initialSelected }


type Msg key
    = SetSelected key


update : Msg key -> Model key -> Model key
update msg model =
    case msg of
        SetSelected selected ->
            { model | selected = selected }


view : Theme -> List (Attribute msg) -> Dict key (TabData msg) -> (Msg key -> msg) -> Model key -> Element msg
view theme attrs tabs toMsg model =
    let
        viewTab key { label } =
            let
                buttonAttrs =
                    (if model.selected == key then
                        [ Font.color (Theme.backgroundColor theme), Background.color (Theme.lineColor theme) ]

                     else
                        [ Background.color (Theme.backgroundColor theme) ]
                    )
                        ++ [ paddingEach { top = 5, left = 5, right = 5, bottom = 0 }, width (fillPortion 1), height (fillPortion 1), Font.center ]
            in
            button buttonAttrs { onPress = Just (toMsg (SetSelected key)), label = label }
    in
    column attrs
        [ row [ width fill, height fill, clip, Border.width 1, Border.rounded 5, Background.color (Theme.lineColor theme), spacing 1 ] (Dict.values (Dict.map viewTab tabs) |> List.reverse)
        , Dict.get model.selected tabs
            |> Maybe.map .content
            |> Maybe.withDefault Element.none
        ]
