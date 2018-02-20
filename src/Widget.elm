module Widget exposing (..)


type Widget
    = Linechart Graphdata
    | Barchart Graphdata
    | Text Log


type alias Point a =
    { x : a
    , y : a
    }


type alias Graphdata =
    { values : List (Point Float)
    , xAxis : Maybe String
    , yAxis : Maybe String
    }


type alias Log =
    { values : List String
    , description : Maybe String
    }
