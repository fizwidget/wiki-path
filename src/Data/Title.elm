module Data.Title exposing (Title, RemoteTitlePair, TitleError(..), from, value, decoder)

import Http
import Json.Decode exposing (Decoder, map, string)
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


decoder : Decoder Title
decoder =
    map from string
