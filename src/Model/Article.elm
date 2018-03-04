module Model.Article exposing (Article)

import Model.Title as Title exposing (Title)
import Model.Content as Content exposing (Content)


type alias Article =
    { title : Title
    , content : Content
    }


create : String -> String -> Result String Article
create title html =
    let
        titleMaybe =
            Title.create title

        createArticle title =
            { title = title, content = Content.create html }
    in
        Result.map createArticle titleMaybe
