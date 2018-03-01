module LinkExtractor exposing (Link, getLinks)

import HtmlParser exposing (parse)
import HtmlParser.Util exposing (getElementsByTagName, filterMapElements, getValue, textContent)


type alias Link =
    { name : String
    , destination : String
    }


getLinks : String -> List Link
getLinks html =
    parse html
        |> getElementsByTagName "a"
        |> filterMapElements
            (\_ attributes children ->
                case getValue "href" attributes of
                    Just href ->
                        Just
                            { name = textContent children
                            , destination = href
                            }

                    Nothing ->
                        Nothing
            )
