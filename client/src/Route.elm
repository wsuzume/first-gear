module Route exposing (Route(..), fromUrl)

import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser)

type Route
    = Home
    | Settings
    | Portfolio
    | EditPortfolio
    | Board
--    | Develop


parser : Parser (Route -> a) a
parser =
    Parser.oneOf
        [ Parser.map Home Parser.top
        , Parser.map Settings (Parser.s "settings")
        , Parser.map Portfolio (Parser.s "portfolio")
        , Parser.map EditPortfolio (Parser.s "editportfolio")
        , Parser.map Board (Parser.s "board")
--        , Parser.map Develop (Parser.s "develop")
        ]

fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url

