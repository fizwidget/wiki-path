module PathfindingPage.Init exposing (init)

import Common.Model exposing (Title(Title), Article, stringValue)
import Common.Service exposing (requestArticle)
import Model exposing (Model(PathfindingPage))
import Messages exposing (Msg(PathfindingPage))
import PathfindingPage.Messages exposing (PathfindingMsg(ArticleReceived))
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
            , error = Nothing
            }

        -- TODO: Set error here
        initialCmd =
            getNextCandidate start initialModel
                |> Maybe.map stringValue
                |> Maybe.map (requestArticle ArticleReceived)
                |> Maybe.withDefault Cmd.none
    in
        ( Model.PathfindingPage initialModel, Cmd.map Messages.PathfindingPage initialCmd )
