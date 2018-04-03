module Common.Model.Title exposing (Title, from, value, toLink)


type Title
    = Title String


from : String -> Title
from =
    Title


value : Title -> String
value (Title title) =
    title


toLink : Title -> String
toLink title =
    "https://en.wikipedia.org/wiki/" ++ (value title)
