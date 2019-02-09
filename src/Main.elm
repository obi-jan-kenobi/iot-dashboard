module Main exposing (..)

import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Dict exposing (..)
import WebSocket
import Time exposing (..)
import Json.Decode exposing (..)
import Widget exposing (..)
import LineChart exposing (..)


main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


type alias WebSocketUrl =
    String


type alias SensorId =
    String


type alias Model =
    { sensors : Dict SensorId ( WebSocketUrl, Chart )
    }


init : ( Model, Cmd Msg )
init =
    ( Model <| singleton "bcde" ( "ws://127.0.0.1:3000/", Linechart { x = "x", y = "x" } (Timeseries []) ), Cmd.none )


type Msg
    = UpdateValue SensorId Time Float
    | UpdateLog SensorId String
    | Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg { sensors } =
    case msg of
        Noop ->
            ( { sensors = sensors }
            , Cmd.none
            )

        UpdateValue sensor x y ->
            ( { sensors =
                    Dict.update sensor
                        (\tuple ->
                            case tuple of
                                Nothing ->
                                    Nothing

                                Just ( ws, widget ) ->
                                    Just ( ws, updateWidget widget (Point x y) )
                        )
                        sensors
              }
            , Cmd.none
            )

        UpdateLog sensor log ->
            ( { sensors =
                    Dict.update sensor
                        (\tuple ->
                            case tuple of
                                Nothing ->
                                    Nothing

                                Just ( ws, widget ) ->
                                    Just ( ws, widget )
                        )
                        sensors
              }
            , Cmd.none
            )


updateWidget : Chart -> Point Time Float -> Chart
updateWidget chart new =
    case chart of
        Linechart axis data ->
            Linechart axis <| appendMeasurevalue data new

        Barchart axis data ->
            Barchart axis <| appendMeasurevalue data new


appendMeasurevalue : Timeseries -> Point Time Float -> Timeseries
appendMeasurevalue ts value =
    mapTimeseries (\xs -> value :: xs) ts


mapTimeseries f (Timeseries x) =
    Timeseries <| f x


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ WebSocket.listen "ws://127.0.0.1:3000/measurevalues" foobar
        ]


type alias NewValue =
    { id : String
    , timestamp : Time
    , value : Float
    }


foobar string =
    case decodeString valueDecoder string of
        Ok { id, timestamp, value } ->
            UpdateValue id timestamp value

        Err _ ->
            Noop


valueDecoder =
    map3 NewValue (field "id" string) (field "timestamp" float) (field "value" float)



-- VIEW


type alias ChartPoint =
    { x : Time
    , y : Float
    }


view : Model -> Html Msg
view model =
    div [] <|
        List.map
            (\( _, ( _, chart ) ) ->
                case chart of
                    Linechart axis (Timeseries list) ->
                        view1 .x .y <| List.map (\(Point x y) -> ChartPoint x y) list

                    Barchart axis list ->
                        div [] []
            )
        <|
            toList model.sensors
