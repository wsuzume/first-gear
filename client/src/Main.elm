module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, text, div, h3, button)
import Html.Events exposing (onClick)
import Json.Encode
import Json.Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)

import Port exposing (elm2js, js2elm)
import Route exposing (Route, fromUrl)
import Session exposing (Session, Internals, createSession, navKeyOf)

import Page.Home as Home
import Page.Settings as Settings
import Page.Portfolio as Portfolio
import Page.EditPortfolio as EditPortfolio
import Page.Board as Board
import Page.Develop as Develop

main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }

-- MODEL

type Model
    = NotFound Session
    | Home Session Home.Model
    | Settings Session Settings.Model
    | Portfolio Session Portfolio.Model
    | EditPortfolio Session EditPortfolio.Model
    | Board Session Board.Model
    | Develop Session Develop.Model

toSession : Model -> Session
toSession model =
    case model of
        NotFound session ->
            session
        
        Home session _ ->
            session

        Settings session _ ->
            session

        Portfolio session _ ->
            session

        EditPortfolio session _ ->
            session

        Board session _ ->
            session
        
        Develop session _ ->
            session


-- HELPERS

wrapWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
wrapWith toModel toMsg (subModel, subMsg) =
    ( toModel subModel, Cmd.map toMsg subMsg )

load : Maybe Route -> Model -> ( Model, Cmd Msg )
load maybeRoute model =
    let
        _ = Debug.log "load" maybeRoute
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Home ->
            Home.init session
                |> wrapWith (Home session) GotHomeMsg

        Just Route.Settings ->
            Settings.init session
                |> wrapWith (Settings session) GotSettingsMsg

        Just Route.Portfolio ->
            Portfolio.init session
                |> wrapWith (Portfolio session) GotPortfolioMsg

        Just Route.EditPortfolio ->
            EditPortfolio.init session
                |> wrapWith (EditPortfolio session) GotEditPortfolioMsg

        Just Route.Board ->
            Board.init session
                |> wrapWith (Board session) GotBoardMsg

        Just Route.Develop ->
            Develop.init session
                |> wrapWith (Develop session) GotDevelopMsg


-- INIT

type alias Flags
    = Json.Encode.Value

init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        _ = Debug.log "init" (Port.decodePortMsg flags)
    in
    load (fromUrl url) <|
        NotFound (createSession key)

-- UPDATE

type SubMsg
    = NoOps
    | Send

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotHomeMsg Home.Msg
    | GotSettingsMsg Settings.Msg
    | GotPortfolioMsg Portfolio.Msg
    | GotEditPortfolioMsg EditPortfolio.Msg
    | GotBoardMsg Board.Msg
    | GotDevelopMsg Develop.Msg
    | Recv Json.Decode.Value


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    let
        _ = Debug.log "update" message
        session =
            toSession model
    in
    case ( message, model ) of
        ( LinkClicked urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    case fromUrl url of
                        Just _ ->
                            ( model, Nav.pushUrl (navKeyOf session) (Url.toString url) )

                        Nothing ->
                            ( model, Nav.load <| Url.toString url )

                Browser.External href ->
                    if String.length href == 0 then
                        ( model, Cmd.none )

                    else
                        ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            load (fromUrl url) model

        ( GotHomeMsg msg, Home _ subModel ) ->
            Home.update msg subModel
                |> wrapWith (Home session) GotHomeMsg

        ( GotSettingsMsg msg, Settings _ subModel ) ->
            Settings.update msg subModel
                |> wrapWith (Settings session) GotSettingsMsg

        ( GotPortfolioMsg msg, Portfolio _ subModel ) ->
            Portfolio.update msg subModel
                |> wrapWith (Portfolio session) GotPortfolioMsg

        ( GotEditPortfolioMsg msg, EditPortfolio _ subModel ) ->
            EditPortfolio.update msg subModel
                |> wrapWith (EditPortfolio session) GotEditPortfolioMsg

        ( GotBoardMsg msg, Board _ subModel ) ->
            Board.update msg subModel
                |> wrapWith (Board session) GotBoardMsg

        ( GotDevelopMsg msg, Develop _ subModel ) ->
            Develop.update msg subModel
                |> wrapWith (Develop session) GotDevelopMsg

        ( Recv msg, _ ) ->
            let
                _ = Debug.log "Recv" (Port.decodePortMsg msg)
            in
            ( model, Cmd.none )

        ( _, _ ) ->
            ( model, Cmd.none )


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
    let
        _ = Debug.log "subscriptions" model
        pageSubscriptions m =
            case m of
                NotFound _ ->
                    Sub.none

                Home _ subModel ->
                    Sub.map GotHomeMsg (Home.subscriptions subModel)

                Settings _ subModel ->
                    Sub.map GotSettingsMsg (Settings.subscriptions subModel)

                Portfolio _ subModel ->
                    Sub.map GotPortfolioMsg (Portfolio.subscriptions subModel)

                EditPortfolio _ subModel ->
                    Sub.map GotEditPortfolioMsg (EditPortfolio.subscriptions subModel)

                Board _ subModel ->
                    Sub.map GotBoardMsg (Board.subscriptions subModel)

                Develop _ subModel ->
                   Sub.map GotDevelopMsg (Develop.subscriptions subModel)
    in
    Sub.batch
    [ pageSubscriptions model
    , js2elm Recv
    ]

-- VIEW
view : Model -> Browser.Document Msg
view model =
    let
        _ = Debug.log "view" model
        viewPage toMsg { title, body } =
            { title = title, body = List.map (Html.map toMsg) body }
    in
    case model of
        NotFound _ ->
            viewNotFoundPage

        Home _ subModel ->
            viewPage GotHomeMsg (Home.view subModel)

        Settings _ subModel ->
            viewPage GotSettingsMsg (Settings.view subModel)

        Portfolio _ subModel ->
            viewPage GotPortfolioMsg (Portfolio.view subModel)

        EditPortfolio _ subModel ->
            viewPage GotEditPortfolioMsg (EditPortfolio.view subModel)

        Board _ subModel ->
            viewPage GotBoardMsg (Board.view subModel)

        Develop _ subModel ->
            viewPage GotDevelopMsg (Develop.view subModel)

-- NOTFOUND
viewNotFoundPage : { title : String, body : List (Html Msg) }
viewNotFoundPage = 
    { title = "Not Found", body = [ Html.text "Not Found" ] }