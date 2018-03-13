module Setup.View exposing (view)

import Html exposing (Html, div)
import Setup.Model
import Setup.Messages exposing (Msg)
import Setup.View.Inputs exposing (titleInputs, loadArticlesButton)
import Setup.View.Content exposing (articlesContent)


view : Setup.Model.Model -> Html Msg
view model =
    div []
        [ titleInputs model
        , loadArticlesButton
        , articlesContent model.sourceArticle model.destinationArticle
        ]
