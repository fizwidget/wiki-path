module Common.Model.Title exposing (Title, from, value)


type Title
    = Title String


from : String -> Title
from =
    Title


value : Title -> String
value (Title title) =
    title