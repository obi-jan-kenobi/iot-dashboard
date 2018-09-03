module Main exposing (Model, Msg(..), WebSocketUrl, init, main, update, view)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import WebSocket
import Widget exposing (..)


main =
    Html.program
        { model = model
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias WebSocketUrl =
    String



-- MODEL


type alias Model =
    { widgets : List ( WebSocketUrl, Widget )
    }


init : ( Model, Cmd Msg )
init =
    ( Model [], Cmd.none )



-- UPDATE


type Msg
    = Increment
    | Decrement


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (toString model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]
