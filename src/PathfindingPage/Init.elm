module PathfindingPage.Init exposing (init)

import Common.Model exposing (Title(Title), Article, unbox)
import Common.Service exposing (requestArticle)
import PathfindingPage.Model exposing (Model)
import PathfindingPage.Messages exposing (Msg(..))
import PathfindingPage.Util exposing (getNextCandidate)


type alias InitArgs =
    { start : Article
    , end : Article
    }


init : InitArgs -> ( Model, Cmd Msg )
init { start, end } =
    let
        initialModel =
            { start = start
            , end = end
            , stops = []
            }

        initialCmd =
            getNextCandidate start initialModel
                |> Maybe.map unbox
                |> Maybe.map (requestArticle ArticleReceived)
                |> Maybe.withDefault Cmd.none
    in
        ( initialModel, initialCmd )
