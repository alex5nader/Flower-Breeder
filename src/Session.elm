module Session exposing (Session, decoder, withSize)

import Browser.Navigation as Nav
import Json.Decode as Decode exposing (Decoder)
import Settings exposing (Settings)
import WindowSize exposing (WindowSize)


type alias Session =
    { navKey : Nav.Key
    , windowSize : WindowSize
    , settings : Settings
    }


withSize : Session -> WindowSize -> Session
withSize session newSize =
    { session | windowSize = newSize }


decoder : Nav.Key -> WindowSize -> Decoder Session
decoder navKey windowSize =
    Decode.map (Session navKey windowSize)
        (Decode.field "settings" Settings.decoder)
