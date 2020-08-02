module Page.Develop exposing(Model, Msg, init, update, subscriptions, view)

import Html exposing (Html, text, div, h3, button, input, form)
import Html.Attributes exposing (style, id, type_, placeholder)

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
    { title = "ignite - Develop"
    , body =
        [ div
            [ style "display" "table"
            , style "table-layout" "fixed"
            , style "width" "100%"
            ]
            [ div
                [ id "message_sender"
                , style "display" "table-cell"
                , style "border" "1px solid black"
                , style "width" "32em"
                ]
                [ div
                    [ style "border" "1px solid black"
                    , style "margin" "3px"
                    , style "padding" "15px"
                    ]
                    [ form
                        []
                        [ h3 [ style "margin" "0.3em" ] [ text "Sign up" ]
                        , input [ id "username", type_ "text", placeholder "username" ] []
                        , input [ id "password", type_ "text", placeholder "password" ] []
                        , input [ id "password_confirm", type_ "text", placeholder "password confirm" ] []
                        , button [] [ text "Send" ]
                        , button [] [ text "Reset" ]
                        ]
                    ]
                , div
                    [ style "border" "1px solid black"
                    , style "margin" "3px"
                    , style "padding" "15px"
                    ]
                    [ form
                        []
                        [ h3 [ style "margin" "0.3em" ] [ text "Sign in" ]
                        , input [ id "username_signin", type_ "text", placeholder "username" ] []
                        , input [ id "password_signin", type_ "text", placeholder "password" ] []
                        , button [] [ text "Send" ]
                        , button [] [ text "Reset" ]
                        , button [] [ text "Sign out" ]
                        ]
                    ]
                , div
                    [ style "border" "1px solid black"
                    , style "margin" "3px"
                    , style "padding" "15px"
                    ]
                    [ form
                        []
                        [ h3 [ style "margin" "0.3em" ] [ text "Settings" ]
                        , input [ id "handlename", type_ "text", placeholder "handlename" ] []
                        , input [ id "avatar", type_ "text", placeholder "avatar" ] []
                        , button [] [ text "Send" ]
                        , button [] [ text "Reset" ]
                        ]
                    ]
                ]
            ]
        ]
    }

