module Page.Home exposing(Model, Msg, init, update, subscriptions, view)

import Html exposing (Html, text)

import Session exposing (Session)

type alias Model =
    { session : Session
    }

type Msg
    = NoOps

init : Session -> ( Model, Cmd Msg )
init session =
    ( Model session
    , Cmd.none
    )

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOps ->
            ( model, Cmd.none )

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

view : Model -> { title : String, body : List (Html Msg) }
view model =
    { title = "ignite"
    , body =
        [ text "Template"
        ]
    }

