module Page.Blank exposing (view)

import Element exposing (Element)
import Page


view : Page.Data msg
view =
    { title = ""
    , content = Element.none
    }
