module Request.Wikipedia exposing (apiBaseUrl)

import Request.Url exposing (Url)


apiBaseUrl : Url
apiBaseUrl =
    "https://en.wikipedia.org/w/api.php"
