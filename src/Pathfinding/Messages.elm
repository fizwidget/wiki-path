module Pathfinding.Messages exposing (PathfindingMsg(..))

import Common.Model.Article exposing (RemoteArticle)
import Common.Model.Title exposing (Title)


type PathfindingMsg
    = ArticleReceived RemoteArticle (List Title)
    | BackToSetup
