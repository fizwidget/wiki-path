module Pathfinding.Messages exposing (PathfindingMsg(..))

import Common.Article.Model exposing (ArticleResult)
import Common.Path.Model exposing (Path)


type PathfindingMsg
    = FetchArticleResponse Path ArticleResult
    | BackToSetup
