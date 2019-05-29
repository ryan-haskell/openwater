module Main exposing (main)

import Application
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Page.WeekView
import Url exposing (Url)


type alias Context =
    { user : Maybe String
    }


type alias Flags =
    ()


type alias Model =
    { key : Nav.Key
    , url : Url
    , context : Context
    , page : PageModel
    }


type PageModel
    = WeekView Page.WeekView.Model


type Msg
    = AppRequestedUrl UrlRequest
    | AppChangedUrl Url
    | WeekViewPageSentMsg Page.WeekView.Model Page.WeekView.Msg


pages =
    { weekView =
        Application.createPageHandler
            { init = Page.WeekView.init
            , update = Page.WeekView.update
            , view = Page.WeekView.view
            , subscriptions = Page.WeekView.subscriptions
            , toMsg = WeekViewPageSentMsg
            , toModel = WeekView
            }
    }


main : Program Flags Model Msg
main =
    Browser.application
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        , onUrlRequest = AppRequestedUrl
        , onUrlChange = AppChangedUrl
        }


init : Flags -> Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        context =
            Context Nothing

        page =
            pages.weekView.init context
    in
    ( { key = key
      , url = url
      , context = context
      , page = page.model
      }
    , page.cmd
    )


view : Model -> Browser.Document Msg
view model =
    { title = "Document"
    , body = [ viewPage model ]
    }


viewPage : Model -> Html Msg
viewPage { url, page, context } =
    case page of
        WeekView model ->
            pages.weekView.view model context


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        AppRequestedUrl _ ->
            ( model, Cmd.none )

        AppChangedUrl url ->
            ( { model | url = url }
            , Cmd.none
            )

        WeekViewPageSentMsg model_ msg_ ->
            pages.weekView.update msg_ model_ model.context model


subscriptions : Model -> Sub Msg
subscriptions { page, context } =
    case page of
        WeekView model ->
            pages.weekView.subscriptions model context
