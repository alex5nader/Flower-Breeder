module Dropdown exposing (Model, Msg(..), init, update, view)

import AssocList as Dict exposing (Dict)
import Element exposing (Attribute, Element, centerX, centerY, clip, column, el, fill, height, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (Label(..), button)
import Maybe.Extra
import Theme exposing (Theme)


type alias Model key =
    { visible : Bool
    , selected : key
    }


init : key -> Model key
init selected =
    { visible = False
    , selected = selected
    }


type Msg key
    = SetVisibility Bool
    | SetSelected key


update : Msg key -> Model key -> Model key
update msg model =
    case msg of
        SetVisibility visible ->
            { model | visible = visible }

        SetSelected selected ->
            { model
                | selected = selected
                , visible = False
            }


dropdownItem : Theme -> key -> (Msg key -> msg) -> key -> ( Element msg, Bool ) -> Element msg
dropdownItem theme selected toMsg value ( label, _ ) =
    let
        attrs =
            if value == selected then
                [ Background.color (Theme.lineColor theme), Font.color (Theme.backgroundColor theme) ]

            else
                []
    in
    button
        (width fill :: attrs)
        { onPress = Just (toMsg (SetSelected value)), label = label }


autoCompleteDropdown : Theme -> key -> Dict key ( Element msg, Bool ) -> (Msg key -> msg) -> Element msg
autoCompleteDropdown theme selected options toMsg =
    column
        [ width fill
        , Border.widthEach { top = 0, left = 1, bottom = 1, right = 1 }
        , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 10, bottomRight = 10 }
        , Background.color (Theme.backgroundColor theme)
        , clip
        ]
        (options
            |> Dict.filter (\_ ( _, show ) -> show)
            |> Dict.map (dropdownItem theme selected toMsg)
            |> Dict.values
        )


view : Theme -> Dict key ( Element msg, Bool ) -> (Msg key -> msg) -> Model key -> Element msg
view theme options toMsg model =
    let
        outerAttrs =
            (if model.visible then
                [ Element.below (autoCompleteDropdown theme model.selected options toMsg) ]

             else
                []
            )
                ++ [ height fill
                   , width fill
                   , centerX
                   , centerY
                   ]

        innerAttrs =
            (if model.visible then
                Border.roundEach { topLeft = 10, topRight = 10, bottomLeft = 0, bottomRight = 0 }

             else
                Border.rounded 10
            )
                :: [ Border.width 1
                   , width fill
                   , height fill
                   , onClick (toMsg (SetVisibility (not model.visible)))
                   ]
    in
    el
        outerAttrs
        (button innerAttrs
            { onPress = Just (toMsg (SetVisibility True))
            , label =
                Dict.get model.selected options
                    |> Maybe.Extra.orElse (Dict.values options |> List.head)
                    |> Maybe.map Tuple.first
                    |> Maybe.withDefault Element.none
            }
        )
