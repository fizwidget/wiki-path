module Pathfinding.Messages exposing (PathfindingMsg(..))

import Common.Model.Article exposing (RemoteArticle)


type PathfindingMsg
    = ArticleReceived RemoteArticle
    | BackToSetup
