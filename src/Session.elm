module Session exposing (Session(..), fromSettings, toKey, toSettings)

import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Ports
import Settings exposing (Settings)


type Session
    = Session Nav.Key Settings


toJson : Session -> Value
toJson session =
    case session of
        Session _ settings ->
            Encode.object
                [ ( "settings", Settings.toJson settings ) ]


decoder : Nav.Key -> Decoder Session
decoder navKey =
    Decode.map (Session navKey)
        (Decode.field "settings" Settings.decoder)


toKey : Session -> Nav.Key
toKey session =
    case session of
        Session key _ ->
            key


toSettings : Session -> Settings
toSettings session =
    case session of
        Session _ settings ->
            settings


fromSettings : Nav.Key -> Settings -> Session
fromSettings key settings =
    Session key settings
