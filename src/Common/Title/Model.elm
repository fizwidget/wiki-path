module Common.Title.Model exposing (Title, from, value)


type Title
    = Title String


from : String -> Title
from =
    Title


value : Title -> String
value (Title title) =
    title
