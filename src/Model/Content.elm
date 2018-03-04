module Model.Content exposing (Content, create)

import HtmlParser exposing (Node, parse)


type alias Content =
    List Node


create : String -> Content
create =
    parse
