module Route exposing (Route(..), fromUrl, replaceUrl, toUrl)

import Browser.Navigation as Nav
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, oneOf, s)


type Route
    = Root
    | Home
    | About


toUrl : Route -> String
toUrl route =
    "/" ++ String.join "/" (toParts route)


parser : Parser (Route -> a) a
parser =
    oneOf <|
        [ Parser.map Home Parser.top
        , Parser.map About (s "about")
        ]


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (toUrl route)


toParts : Route -> List String
toParts route =
    case route of
        Root ->
            [ "" ]

        Home ->
            [ "" ]

        About ->
            [ "about" ]
