module Common.Model.Title exposing (Title, from, value, toUrl)


type Title
    = Title String


from : String -> Title
from =
    Title


value : Title -> String
value (Title title) =
    title


toUrl : Title -> String
toUrl title =
    "https://en.wikipedia.org/wiki/" ++ (value title)
