module Main exposing (..)

import Browser exposing (Document, UrlRequest(..))
import Browser.Events
import Browser.Navigation as Nav
import Html exposing (Html)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Json
import Page
import Page.About as About
import Page.Blank as Blank
import Page.Home as Home
import Page.NotFound as NotFound
import Platform.Cmd as Cmd
import Platform.Sub as Sub
import Route exposing (Route)
import Session exposing (Session)
import Settings exposing (Settings)
import Url exposing (Url)
import WindowSize exposing (WindowSize)


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | About About.Model


toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        About about ->
            About.toSession about


withSession : Model -> Session -> Model
withSession model newSession =
    case model of
        Redirect _ ->
            Redirect newSession

        NotFound _ ->
            NotFound newSession

        Home home ->
            Home (Home.withSession home newSession)

        About about ->
            About (About.withSession about newSession)


init : Json.Value -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flagsValue url navKey =
    let
        ( settings, windowSize ) =
            let
                rootDecoder =
                    Decode.map2 Tuple.pair
                        (Decode.field "settings" (Decode.nullable Decode.string))
                        (Decode.field "windowSize" WindowSize.decoder)
            in
            Decode.decodeValue rootDecoder flagsValue
                |> Result.map (Tuple.mapFirst (Maybe.map (Decode.decodeString Settings.decoder) >> Maybe.withDefault (Ok Settings.default)))
                |> Result.withDefault ( Ok Settings.default, WindowSize 0 0 )
                |> Tuple.mapFirst (Result.withDefault Settings.default)
    in
    changeRouteTo (Route.fromUrl url) (Redirect (Session navKey windowSize settings))


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Home.Msg
    | GotAboutMsg About.Msg
    | GotSession Session
    | Resize WindowSize


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl session.navKey Route.Home )

        Just Route.About ->
            About.init session |> updateWith About GotAboutMsg model

        Just Route.Home ->
            Home.init session |> updateWith Home GotHomeMsg model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (toSession model).navKey (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( Resize newSize, _ ) ->
            ( withSession model (Session.withSize (toSession model) newSize)
            , Cmd.none
            )

        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home |> updateWith Home GotHomeMsg model

        ( GotSession session, Redirect _ ) ->
            ( Redirect session
            , Route.replaceUrl session.navKey Route.Home
            )

        ( _, _ ) ->
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> Model -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg _ ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )


view : Model -> Document Msg
view model =
    let
        theme =
            (toSession model).settings.theme

        windowWidth =
            (toSession model).windowSize.width

        viewPage page toMsg config =
            let
                { title, body } =
                    Page.view theme windowWidth page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Redirect _ ->
            Page.view theme windowWidth Page.Other Blank.view

        NotFound _ ->
            Page.view theme windowWidth Page.Other NotFound.view

        Home home ->
            viewPage Page.Home GotHomeMsg (Home.view theme home)

        About about ->
            viewPage Page.About GotAboutMsg (About.view about)


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        modelSubs =
            case model of
                NotFound _ ->
                    Sub.none

                Redirect _ ->
                    Sub.none

                Home home ->
                    Sub.map GotHomeMsg (Home.subscriptions home)

                About about ->
                    Sub.map GotAboutMsg (About.subscriptions about)

        compose21 f g a b =
            g (f a b)
    in
    Sub.batch
        [ modelSubs
        , Browser.Events.onResize (compose21 WindowSize Resize)
        ]


main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = ClickedLink
        , onUrlChange = ChangedUrl
        }
