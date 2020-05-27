module Page.About exposing (Model, Msg, init, subscriptions, toSession, update, view, withSession)

import Element exposing (centerX, centerY, column, fill, height, link, paragraph, spacing, text, width)
import Element.Font as Font exposing (underline)
import Element.Region as Region
import Page
import Session exposing (Session)


type alias Model =
    { session : Session }


toSession : Model -> Session
toSession model =
    model.session


withSession : Model -> Session -> Model
withSession model newSession =
    { model | session = newSession }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session }
    , Cmd.none
    )


type Msg
    = Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msg ->
            ( model, Cmd.none )


view : Model -> Page.Data Msg
view _ =
    { title = "About"
    , content =
        column [ Region.mainContent, width fill, height fill, spacing 30, Font.center ]
            [ paragraph [ centerX, centerY ]
                [ text "Thanks to the creators of these three guides, along with everyone credited by them." ]
            , column [ centerX, centerY, spacing 10 ]
                [ paragraph [ centerX, centerY ]
                    [ link [ underline, centerX ]
                        { url = "https://docs.google.com/document/d/1ARIQCUc5YVEd01D7jtJT9EEJF45m07NXhAm4fOpNvCs"
                        , label = text "ACNH Flower Genetics Guide"
                        }
                    ]
                , paragraph [ centerX, centerY ]
                    [ link [ underline, centerX ]
                        { url = "https://docs.google.com/spreadsheets/d/1rbYbQ0i3SuTu30KTma5dO4uuJWr_SjOZXA1l4UOIHWo"
                        , label = text "ACNH Flower Research"
                        }
                    ]
                , paragraph [ centerX, centerY ]
                    [ link [ underline, centerX ]
                        { url = "https://aiterusawato.github.io/satogu/acnh/"
                        , label = text "Satogu's ACNH Site"
                        }
                    ]
                ]
            ]
    }


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none
