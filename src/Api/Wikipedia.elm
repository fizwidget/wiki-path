module Api.Wikipedia exposing (apiBaseUrl)

import Api.Url exposing (Url)


apiBaseUrl : Url
apiBaseUrl =
    "https://en.wikipedia.org/w/api.php"
