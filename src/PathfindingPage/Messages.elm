module PathfindingPage.Messages exposing (PathfindingMsg(..))

import Common.Model exposing (RemoteArticle)


type PathfindingMsg
    = ArticleReceived RemoteArticle
