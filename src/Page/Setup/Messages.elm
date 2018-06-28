module Page.Setup.Messages exposing (SetupMsg(..))

import Data.Article exposing (RemoteArticle)
import Data.Title exposing (RemoteTitlePair)
import Page.Setup.Model exposing (UserInput)


type SetupMsg
    = SourceArticleTitleChange UserInput
    | DestinationArticleTitleChange UserInput
    | FetchArticlesRequest
    | FetchSourceArticleResponse RemoteArticle
    | FetchDestinationArticleResponse RemoteArticle
    | FetchRandomTitlesRequest
    | FetchRandomTitlesResponse RemoteTitlePair
