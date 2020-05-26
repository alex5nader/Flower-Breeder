module Asset.Image exposing (Image, fromFlower, fromFlowerKindAndColor, toElement)

import Element exposing (Element)
import Flower exposing (Flower)
import Flower.Color as Color exposing (FlowerColor)
import Flower.Kind exposing (FlowerKind)


type Image
    = Image String


fromFlowerKindAndColor : FlowerKind -> FlowerColor -> Image
fromFlowerKindAndColor kind color =
    makeImage ("flower/" ++ Flower.Kind.toString kind ++ "/" ++ Color.toString color ++ ".png")


fromFlower : Flower -> Maybe Image
fromFlower flower =
    Maybe.map (fromFlowerKindAndColor flower.kind) (Flower.getColor flower)


makeImage : String -> Image
makeImage filename =
    Image ("/assets/images/" ++ filename)


toElement : List (Element.Attribute msg) -> String -> Image -> Element msg
toElement attrs description image =
    case image of
        Image src ->
            Element.image attrs { src = src, description = description }
