module Page exposing (Data, Page(..), view)

import Browser exposing (Document)
import Element exposing (Element, alignRight, centerX, column, el, fill, height, link, padding, row, spacing, text, width)
import Element.Background as Background
import Element.Border as Border
import Element.Font as Font exposing (bold, underline)
import Element.Region as Region
import Route exposing (Route(..))
import Theme exposing (Theme(..))


type Page
    = Other
    | Home
    | About


type alias Data msg =
    { title : String, content : Element msg }


view : Theme -> Int -> Page -> Data msg -> Document msg
view theme windowWidth page { title, content } =
    let
        viewHeader =
            if windowWidth < 600 then
                viewSmallScreenHeader

            else
                viewLargeScreenHeader
    in
    { title = title ++ " - ACNH Flower Breeder"
    , body =
        [ Element.layout
            [ Background.color (Theme.backgroundColor theme)
            , Font.color (Theme.lineColor theme)
            , Border.color (Theme.lineColor theme)
            ]
          <|
            column [ width fill, height fill ] <|
                [ viewHeader page
                , content
                ]
        ]
    }


viewSmallScreenHeader : Page -> Element msg
viewSmallScreenHeader page =
    let
        linkTo =
            linkFrom page
    in
    row [ Region.navigation, width fill, Border.widthEach { top = 0, left = 0, bottom = 3, right = 0 }, padding 25, spacing 25 ]
        [ el [ centerX ] (linkTo Route.Home (text "Breeder"))
        , el [ centerX ] (linkTo Route.About (text "About"))
        ]


viewLargeScreenHeader : Page -> Element msg
viewLargeScreenHeader page =
    let
        linkTo =
            linkFrom page
    in
    row [ Region.navigation, width fill, padding 25, Border.widthEach { top = 0, left = 0, bottom = 3, right = 0 } ] <|
        [ text "ACNH Flower Breeder"
        , row [ alignRight, spacing 25 ] <|
            [ linkTo Route.Home (text "Breeder")
            , linkTo Route.About (text "About")
            ]
        ]


linkFrom : Page -> Route -> Element msg -> Element msg
linkFrom from to label =
    let
        linkAttrs =
            if isOnPage from to then
                [ bold, underline ]

            else
                []
    in
    link linkAttrs { url = Route.toUrl to, label = label }


isOnPage : Page -> Route -> Bool
isOnPage from to =
    case ( from, to ) of
        ( Home, Route.Home ) ->
            True

        ( About, Route.About ) ->
            True

        _ ->
            False
