module Main exposing (Flags, Model(..), Msg(..), changeRouteTo, init, main, subscriptions, toSession, update, updateWith, view)

import Browser
import Browser.Navigation as Nav
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
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
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )

type alias Flags =
    {}

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

        ( GotIndexMsg subMsg, Index _ subModel ) ->
            updateIndexPage subMsg subModel
                |> updateWith (Index session) GotIndexMsg

        ( GotExampleMsg subMsg, Example _ subModel ) ->
            updateExamplePage subMsg subModel
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
    case model of
        NotFound _ ->
            Sub.none

        Index _ subModel ->
            Sub.map GotIndexMsg (subscriptionsIndexPage subModel)

        Example _ subModel ->
            Sub.map GotExampleMsg (subscriptionsExamplePage subModel)

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
        [ text "Example"
        ]
    }

view : Model -> Browser.Document Msg
view model =
    let
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
