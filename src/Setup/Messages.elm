module Setup.Messages exposing (SetupMsg(..))

import RemoteData exposing (WebData)
import Common.Article.Model exposing (RemoteArticle)
import Common.Title.Model exposing (Title)
import Setup.Model exposing (UserInput)


type SetupMsg
    = SourceArticleTitleChange UserInput
    | DestinationArticleTitleChange UserInput
    | FetchArticlesRequest
    | FetchSourceArticleResult RemoteArticle
    | FetchDestinationArticleResult RemoteArticle
    | RandomizeTitlesRequest
    | RandomizeTitlesResponse (WebData (List Title))
