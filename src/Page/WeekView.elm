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


init : { model : Model, cmd : Cmd Msg }
init =
    { model = Model Nothing
    , cmd = Task.perform AppReceivedNow Time.now
    }


update : Msg -> Model -> { model : Model, cmd : Cmd Msg }
update msg model =
    case msg of
        AppReceivedNow now ->
            ReturnValue { model | now = Just now } Cmd.none


view : Model -> Html Msg
view model =
    div [] [ text "Weekday view?" ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
