module Main exposing (main)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import ModelCmd exposing (ModelCmd)
import Page.WeekView
import Url exposing (Url)


type alias Flags =
    ()


type alias Model =
    { key : Nav.Key
    , url : Url
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
        { initHandler =
            handlePageInit
                { init = Page.WeekView.init
                , toMsg = WeekViewPageSentMsg
                , toModel = WeekView
                }
        , updateHandler =
            handlePageUpdate
                { update = Page.WeekView.update
                , toModel = WeekView
                , toMsg = WeekViewPageSentMsg
                }
        , viewHandler =
            handlePageView
                { view = Page.WeekView.view
                , toMsg = WeekViewPageSentMsg
                }
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
        page =
            pages.weekView.initHandler
    in
    ( { key = key
      , url = url
      , page = page.model
      }
    , page.cmd
    )


type alias PageInitBundle model msg appModel appMsg =
    { init : { model : model, cmd : Cmd msg }
    , toMsg : model -> msg -> appMsg
    , toModel : model -> appModel
    }


handlePageInit : PageInitBundle model msg appModel appMsg -> ModelCmd appModel appMsg
handlePageInit config =
    { model = config.toModel config.init.model
    , cmd = Cmd.map (config.toMsg config.init.model) config.init.cmd
    }


view : Model -> Browser.Document Msg
view model =
    { title = "Document"
    , body = [ viewPage model ]
    }


type alias PageViewBundle model msg appMsg =
    { view : model -> Html msg
    , toMsg : model -> msg -> appMsg
    }


handlePageView :
    PageViewBundle model msg appMsg
    -> model
    -> Html appMsg
handlePageView config model =
    Html.map
        (config.toMsg model)
        (config.view model)


viewPage : Model -> Html Msg
viewPage { url, page } =
    case page of
        WeekView model ->
            pages.weekView.viewHandler model


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        WeekViewPageSentMsg model_ msg_ ->
            pages.weekView.updateHandler msg_ model_ model

        AppRequestedUrl _ ->
            ( model, Cmd.none )

        AppChangedUrl url ->
            ( { model | url = url }
            , Cmd.none
            )


type alias PageUpdateBundle model msg appModel appMsg =
    { update : msg -> model -> { model : model, cmd : Cmd msg }
    , toModel : model -> appModel
    , toMsg : model -> msg -> appMsg
    }


handlePageUpdate :
    PageUpdateBundle model msg appModel appMsg
    -> msg
    -> model
    -> { a | page : appModel }
    -> ( { a | page : appModel }, Cmd appMsg )
handlePageUpdate config msg_ model_ model =
    let
        page =
            config.update msg_ model_
    in
    ( { model | page = config.toModel page.model }
    , Cmd.map (config.toMsg page.model) page.cmd
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.page of
        WeekView model_ ->
            Sub.map
                (WeekViewPageSentMsg model_)
                (Page.WeekView.subscriptions model_)
