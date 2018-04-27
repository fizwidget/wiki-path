module Pathfinding.Messages exposing (PathfindingMsg(..))

import Common.Article.Model exposing (ArticleResult)
import Pathfinding.Model exposing (Path)


type PathfindingMsg
    = FetchArticleResponse Path ArticleResult
