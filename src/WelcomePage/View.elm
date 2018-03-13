module WelcomePage.View exposing (view)

import Html exposing (Html, div)
import WelcomePage.Model
import WelcomePage.Messages exposing (Msg)
import WelcomePage.View.Inputs exposing (titleInputs, loadArticlesButton)
import WelcomePage.View.Content exposing (articlesContent)


view : WelcomePage.Model.Model -> Html Msg
view model =
    div []
        [ titleInputs model
        , loadArticlesButton
        , articlesContent model.sourceArticle model.destinationArticle
        ]
