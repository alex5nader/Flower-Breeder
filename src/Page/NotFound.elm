module Page.NotFound exposing (view)

import Element exposing (Element, centerX, centerY, column, el, text)
import Element.Region as Region
import Page


view : Page.Data msg
view =
    { title = "Page Not Found"
    , content =
        column [ Region.mainContent, centerX, centerY ] <|
            [ el [ Region.heading 1 ] (text "Page Not Found")
            ]
    }
