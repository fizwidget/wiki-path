module Model.Title exposing (Title, create, value)

import String exposing (length)


type Title
    = Title String


create : String -> Result String Title
create title =
    if length title > 0 then
        Title title |> Result.Ok
    else
        Result.Err "Title cannot be empty"


value : Title -> String
value (Title title) =
    title
