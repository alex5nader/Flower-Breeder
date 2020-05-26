module Dropdown exposing (view)

import Element exposing (Attribute, Element, centerX, clip, column, el, fill, height, padding, paddingXY, px, rgb255, spacing, width)
import Element.Background as Background
import Element.Border as Border
import Element.Events exposing (onClick)
import Element.Font as Font
import Element.Input exposing (Label(..), button)
import Theme exposing (Theme)


dropdownItem : Theme -> String -> (String -> msg) -> ( String, Element msg ) -> Element msg
dropdownItem theme selected selectionMsg ( value, label ) =
    let
        attrs =
            if value == selected then
                [ Background.color (Theme.lineColor theme), Font.color (Theme.backgroundColor theme) ]

            else
                []
    in
    button
        (width fill :: attrs)
        { onPress = Just (selectionMsg value), label = label }


autoCompleteDropdown : Theme -> String -> (String -> msg) -> List ( String, Element msg ) -> Element msg
autoCompleteDropdown theme selected selectionMsg options =
    column
        [ width fill
        , Border.widthEach { top = 0, left = 1, bottom = 1, right = 1 }
        , Border.roundEach { topLeft = 0, topRight = 0, bottomLeft = 10, bottomRight = 10 }
        , Background.color (Theme.backgroundColor theme)
        , clip
        ]
        (List.map (dropdownItem theme selected selectionMsg) options)


view : Theme -> (Bool -> msg) -> (String -> msg) -> Bool -> String -> Element msg -> List ( String, Element msg ) -> Element msg
view theme setDropdownVisibility setSelection focused selectedValue selectedDisplay options =
    let
        outerAttrs =
            (if focused then
                [ Element.below (autoCompleteDropdown theme selectedValue setSelection options) ]

             else
                []
            )
                ++ [ height fill
                   , centerX
                   , width (px 146)
                   ]

        innerAttrs =
            (if focused then
                Border.roundEach { topLeft = 10, topRight = 10, bottomLeft = 0, bottomRight = 0 }

             else
                Border.rounded 10
            )
                :: [ Border.width 1
                   , width fill
                   , height fill
                   , onClick (setDropdownVisibility (not focused))
                   ]
    in
    el
        outerAttrs
        (button innerAttrs { onPress = Just (setDropdownVisibility True), label = selectedDisplay })
