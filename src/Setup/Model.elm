module Setup.Model exposing (SetupModel, UserInput)

import RemoteData exposing (WebData)
import Common.Article.Model exposing (RemoteArticle)
import Common.Title.Model exposing (Title)


type alias SetupModel =
    { sourceTitleInput : UserInput
    , destinationTitleInput : UserInput
    , source : RemoteArticle
    , destination : RemoteArticle
    , randomizedTitles : WebData (List Title)
    }


type alias UserInput =
    String
