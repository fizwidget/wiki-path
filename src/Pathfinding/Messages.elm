module Pathfinding.Messages exposing (PathfindingMsg(..))

import Common.Model.Article exposing (ArticleResult)
import Pathfinding.Model exposing (Path)


type PathfindingMsg
    = FetchArticleResponse Path ArticleResult
    | BackToSetup
