module Pathfinding.Messages exposing (PathfindingMsg(..))

import Common.Model.Article exposing (RemoteArticle)
import Pathfinding.Model exposing (Path)


type PathfindingMsg
    = ArticleReceived RemoteArticle Path
    | BackToSetup
