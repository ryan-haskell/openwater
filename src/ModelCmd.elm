module ModelCmd exposing (ModelCmd)


type alias ModelCmd model msg =
    { model : model
    , cmd : Cmd msg
    }
