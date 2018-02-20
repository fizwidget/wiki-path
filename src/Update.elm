module Update exposing (update)

import Model exposing (Model)
import Messages exposing (Message(OnFetchArticle))


update : Message -> Model -> ( Model, Cmd Message )
update msg model =
    case msg of
        OnFetchArticle response ->
            ( { model | articleContent = response }, Cmd.none )
