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
--    | Portfolio Session SubModel
--    | EditPortfolio Session SubModel
--    | Blackboard Session SubModel
--    | Develop Session SubModel

toSession : Model -> Session
toSession model =
    case model of
        NotFound session ->
            session
        
        Home session _ ->
            session
        
--        Develop session _ ->
--            session


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

--        Just DevelopRoute ->
--            initDevelopPage session
--                |> wrapWith (Develop session) GotDevelopMsg


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
--    | GotPortfolioMsg SubMsg
--    | GotDevelopMsg SubMsg
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
            let
                _ = Debug.log "GotHomeMsg" 0
            in
            Home.update msg subModel
                |> wrapWith (Home session) GotHomeMsg

--        ( GotDevelopMsg msg, Develop _ subModel ) ->
--            let
--                _ = Debug.log "GotDevelopMsg" 0
--            in
--            updateDevelopPage msg subModel
--                |> wrapWith (Develop session) GotDevelopMsg

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

--                Develop _ subModel ->
--                   Sub.map GotDevelopMsg (subscriptionsDevelopPage subModel)
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

--        Develop _ subModel ->
--            viewPage GotDevelopMsg (viewDevelopPage subModel)

-- NOTFOUND
viewNotFoundPage : { title : String, body : List (Html Msg) }
viewNotFoundPage = 
    { title = "Not Found", body = [ Html.text "Not Found" ] }