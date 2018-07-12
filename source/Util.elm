module Util exposing (noCmd)


noCmd : model -> ( model, Cmd msg )
noCmd model =
    ( model, Cmd.none )
