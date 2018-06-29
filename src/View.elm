module View exposing (view)

import Html.Styled as Html exposing (Html)
import Model exposing (Model)
import Messages exposing (Msg)
import Views.Page as Page
import Page.Setup.View as Setup
import Page.Pathfinding.View as Pathfinding
import Page.Finished.View as Finished


view : Model -> Html Msg
view model =
    Page.frame (viewContent model)


viewContent : Model -> Html Msg
viewContent model =
    case model of
        Model.Setup innerModel ->
            Setup.view innerModel
                |> Html.map Messages.Setup

        Model.Pathfinding innerModel ->
            Pathfinding.view innerModel
                |> Html.map Messages.Pathfinding

        Model.Finished innerModel ->
            Finished.view innerModel
                |> Html.map Messages.Finished
