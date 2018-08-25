module Data.Title exposing (Title, from, asString)


type Title
    = Title String


from : String -> Title
from =
    Title


asString : Title -> String
asString (Title title) =
    title
