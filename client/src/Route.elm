module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)

type Route
    = Home
--    | Develop


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
--        , Parser.map Develop (Parser.s "develop")
        ]

fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url

