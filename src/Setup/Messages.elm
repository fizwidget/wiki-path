module Setup.Messages exposing (SetupMsg(..))

import Common.Article.Model exposing (RemoteArticle)
import Setup.Model exposing (UserInput)


type SetupMsg
    = SourceArticleTitleChange UserInput
    | DestinationArticleTitleChange UserInput
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
