module Widget exposing (Graphdata, Log, Point, Widget(..))

import Time exposing (..)


type Widget
    = Chart
    | Text Log


type Chart
    = Linechart Axis Timeseries
    | Barchart Axis Timeseries


type alias Axis =
    { x : String, y : String }


type Point a b
    = Point a b


type Timeseries
    = Timeseries (List (Point Time Float))


type alias Log =
    { values : List String
    , description : Maybe String
    }
