module Page.Pathfinding.Messages exposing (PathfindingMsg(..))

import Data.Article exposing (ArticleResult)
import Data.Path exposing (Path)


type PathfindingMsg
    = FetchArticleResponse Path ArticleResult
    | BackToSetup
