module Setup.View exposing (view)

import Html exposing (Html, div)
import Setup.Types
import Setup.View.Inputs exposing (titleInputs, loadArticlesButton)
import Setup.View.Content exposing (articlesContent)


view : Setup.Types.Model -> Html Setup.Types.Msg
view model =
    div []
        [ titleInputs model
        , loadArticlesButton
        , articlesContent model.sourceArticle model.destinationArticle
        ]
