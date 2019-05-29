module Page.WeekView exposing
    ( Model
    , Msg
    , init
    , subscriptions
    , update
    , view
    )

import Html exposing (..)
import Task exposing (Task)
import Time exposing (Posix)


type alias ReturnValue model msg =
    { model : model
    , cmd : Cmd msg
    }


type alias Model =
    { now : Maybe Posix
    }


type Msg
    = AppReceivedNow Posix


init : context -> { model : Model, cmd : Cmd Msg }
init _ =
    { model = Model Nothing
    , cmd = Task.perform AppReceivedNow Time.now
    }


update : context -> Msg -> Model -> { model : Model, cmd : Cmd Msg }
update _ msg model =
    case msg of
        AppReceivedNow now ->
            ReturnValue { model | now = Just now } Cmd.none


view : context -> Model -> Html Msg
view _ model =
    div [] [ text "Weekday view?" ]


subscriptions : context -> Model -> Sub Msg
subscriptions _ model =
    Sub.none
