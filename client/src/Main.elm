port module Main exposing (Flags, Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toSession, update, updateWith, view, elm2js, js2elm)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, div, h3, text)
import Html.Events exposing (onClick)
import Json.Encode as E
import Json.Decode exposing (Decoder, field, string, decodeValue)
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)

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

-- PORTS
port elm2js : E.Value -> Cmd msg
port js2elm : (Json.Decode.Value -> msg) -> Sub msg

tagDecoder : Decoder String
tagDecoder =
    field "tag" string

contentDecoder : Decoder String
contentDecoder =
    field "content" string

-- MODEL

type Session
    = Session Internals

type alias Internals =
    { key : Nav.Key
    }

createSession : Nav.Key -> Session
createSession key =
    Session (Internals key)

navKey : Session -> Nav.Key
navKey (Session internals) =
    internals.key


type alias SubModel =
    { session: Session
    }

type Model
    = NotFound Session
    | Index Session SubModel
    | Example Session SubModel

toSession : Model -> Session
toSession page =
    case page of
        NotFound session ->
            session

        Index session _ ->
            session

        Example session _ ->
            session


-- elevateWith is more better?
updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    let
        _ = Debug.log "updateWith" 0
    in
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )

type alias Flags =
    Json.Decode.Value

-- ROUTE

type Route
    = IndexRoute
    | ExampleRoute


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map IndexRoute Parser.top
        , Parser.map ExampleRoute (Parser.s "example")
        ]

fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url

-- INIT
initIndexPage : Session -> ( SubModel, Cmd SubMsg )
initIndexPage session =
    let
        _ = Debug.log "initIndexPage" session
    in
    ( SubModel session
    , Cmd.none
    )

initExamplePage : Session -> ( SubModel, Cmd SubMsg )
initExamplePage session =
    ( SubModel session
    , Cmd.none
    )

changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        _ = Debug.log "changeRouteTo" maybeRoute
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just IndexRoute ->
            initIndexPage session
                |> updateWith (Index session) GotIndexMsg

        Just ExampleRoute ->
            initExamplePage session
                |> updateWith (Example session) GotExampleMsg


init : Flags -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        _ = Debug.log "init" (decodeValue tagDecoder flags)
    in
    changeRouteTo (fromUrl url)
        (NotFound <|
            createSession key
        )

-- UPDATE

type SubMsg
    = NoOps

type Msg
    = LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url
    | GotIndexMsg SubMsg
    | GotExampleMsg SubMsg
    | Send
    | Recv Json.Decode.Value

updateIndexPage : SubMsg -> SubModel -> ( SubModel, Cmd SubMsg )
updateIndexPage submsg submodel =
    case submsg of
        NoOps ->
            ( submodel, Cmd.none )

updateExamplePage : SubMsg -> SubModel -> ( SubModel, Cmd SubMsg )
updateExamplePage submsg submodel =
    case submsg of
        NoOps ->
            ( submodel, Cmd.none )

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
                            ( model, Nav.pushUrl (navKey session) (Url.toString url) )

                        Nothing ->
                            ( model, Nav.load <| Url.toString url )

                Browser.External href ->
                    if String.length href == 0 then
                        ( model, Cmd.none )

                    else
                        ( model, Nav.load href )

        ( UrlChanged url, _ ) ->
            changeRouteTo (fromUrl url) model

        ( GotIndexMsg _, _ ) ->
            let
                _ = Debug.log "GotIndexMsg" 0
            in
            ( model, Cmd.none )

        ( Recv _, Index _ subModel ) ->
            updateIndexPage NoOps subModel
                |> updateWith (Index session) GotIndexMsg

        ( Recv msg, Example _ subModel ) ->
            let
                _ = Debug.log "receive" (decodeValue tagDecoder msg)
            in
            updateExamplePage NoOps subModel
                |> updateWith (Example session) GotExampleMsg

        ( _, _ ) ->
            ( model, Cmd.none )


-- SUBSCRIPTIONS

subscriptionsIndexPage : SubModel -> Sub SubMsg
subscriptionsIndexPage model =
    Sub.none

subscriptionsExamplePage : SubModel -> Sub SubMsg
subscriptionsExamplePage model =
    Sub.none

subscriptions : Model -> Sub Msg
subscriptions model =
    let
        _ = Debug.log "subscriptions" model
        pageSubs m =
            case m of
                NotFound _ ->
                    Sub.none

                Index _ subModel ->
                    Sub.map GotIndexMsg (subscriptionsIndexPage subModel)

                Example _ subModel ->
                   Sub.map GotExampleMsg (subscriptionsExamplePage subModel)
    in
    Sub.batch
    [ js2elm Recv
    , pageSubs model
    ]

-- VIEW
viewIndexPage : SubModel -> { title : String, body : List (Html SubMsg) }
viewIndexPage submodel =
    { title = "ignite - index"
    , body =
        [ text "Index"
        ]
    }

viewExamplePage : SubModel -> { title : String, body : List (Html SubMsg) }
viewExamplePage submodel =
    { title = "ignite - example"
    , body =
        [ h3 []
            [ text "Example"
            ]
        ]
    }

view : Model -> Browser.Document Msg
view model =
    let
        _ = Debug.log "view" model
        viewPage toMsg { title, body } =
            { title = title, body = List.map (Html.map toMsg) body }
    in
    case model of
        NotFound _ ->
            { title = "Not Found", body = [ Html.text "Not Found" ] }

        Index _ subModel ->
            viewPage GotIndexMsg (viewIndexPage subModel)

        Example _ subModel ->
            viewPage GotExampleMsg (viewExamplePage subModel)
