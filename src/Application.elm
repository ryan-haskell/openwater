module Application exposing (createPageHandler)

import Html exposing (Html)


type alias PageHandlerConfig context model msg appModel appMsg =
    { init : context -> { model : model, cmd : Cmd msg }
    , update : context -> msg -> model -> { model : model, cmd : Cmd msg }
    , view : context -> model -> Html msg
    , subscriptions : context -> model -> Sub msg
    , toMsg : model -> msg -> appMsg
    , toModel : model -> appModel
    }


type alias PageHandler a context model msg appModel appMsg =
    { init : PageInitHandler context appModel appMsg
    , update : PageUpdateHandler a context model msg appModel appMsg
    , view : PageViewHandler context model appMsg
    , subscriptions : PageSubscriptionsHandler context model appMsg
    }


type alias PageInitHandler context appModel appMsg =
    context -> { model : appModel, cmd : Cmd appMsg }


type alias PageUpdateHandler a context model msg appModel appMsg =
    msg
    -> model
    -> context
    -> { a | page : appModel }
    -> ( { a | page : appModel }, Cmd appMsg )


type alias PageViewHandler context model appMsg =
    model
    -> context
    -> Html appMsg


type alias PageSubscriptionsHandler context model appMsg =
    model
    -> context
    -> Sub appMsg


createPageHandler : PageHandlerConfig context model msg appModel appMsg -> PageHandler a context model msg appModel appMsg
createPageHandler { init, update, view, subscriptions, toMsg, toModel } =
    { init =
        handlePageInit
            { init = init
            , toMsg = toMsg
            , toModel = toModel
            }
    , update =
        handlePageUpdate
            { update = update
            , toModel = toModel
            , toMsg = toMsg
            }
    , view =
        handlePageView
            { view = view
            , toMsg = toMsg
            }
    , subscriptions =
        handlePageSubscriptions
            { subscriptions = subscriptions
            , toMsg = toMsg
            }
    }



-- INIT


type alias PageInitConfig context model msg appModel appMsg =
    { init : context -> { model : model, cmd : Cmd msg }
    , toMsg : model -> msg -> appMsg
    , toModel : model -> appModel
    }


handlePageInit :
    PageInitConfig context model msg appModel appMsg
    -> PageInitHandler context appModel appMsg
handlePageInit config context =
    let
        page =
            config.init context
    in
    { model = config.toModel page.model
    , cmd = Cmd.map (config.toMsg page.model) page.cmd
    }



-- UPDATE


type alias PageUpdateConfig context model msg appModel appMsg =
    { update : context -> msg -> model -> { model : model, cmd : Cmd msg }
    , toModel : model -> appModel
    , toMsg : model -> msg -> appMsg
    }


handlePageUpdate :
    PageUpdateConfig context model msg appModel appMsg
    -> PageUpdateHandler a context model msg appModel appMsg
handlePageUpdate config msg_ model_ context model =
    let
        page =
            config.update context msg_ model_
    in
    ( { model | page = config.toModel page.model }
    , Cmd.map (config.toMsg page.model) page.cmd
    )



-- VIEW


type alias PageViewConfig context model msg appMsg =
    { view : context -> model -> Html msg
    , toMsg : model -> msg -> appMsg
    }


handlePageView :
    PageViewConfig context model msg appMsg
    -> PageViewHandler context model appMsg
handlePageView config model context =
    Html.map
        (config.toMsg model)
        (config.view context model)



-- SUBSCRIPTIONS


type alias PageSubscriptionsConfig context model msg appMsg =
    { toMsg : model -> msg -> appMsg
    , subscriptions : context -> model -> Sub msg
    }


handlePageSubscriptions :
    PageSubscriptionsConfig context model msg appMsg
    -> PageSubscriptionsHandler context model appMsg
handlePageSubscriptions config model context =
    Sub.map
        (config.toMsg model)
        (config.subscriptions context model)
