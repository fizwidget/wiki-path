module Common.Title.Model exposing (Title, RemoteTitlePair, TitleError(..), from, value)

import Http
import RemoteData exposing (RemoteData)


type Title
    = Title String


from : String -> Title
from =
    Title


value : Title -> String
value (Title title) =
    title


type alias RemoteTitlePair =
    RemoteData TitleError ( Title, Title )


type TitleError
    = UnexpectedTitleCount
    | HttpError Http.Error
