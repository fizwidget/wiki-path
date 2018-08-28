module Article.Id exposing (Id, from, asString)

import Json.Decode as Decode exposing (Decoder)


type Id
    = Id String


from : String -> Id
from =
    Id


asString : Id -> String
asString (Id value) =
    value


decoder : Decoder Id
decoder =
    Decode.map Id Decode.string
