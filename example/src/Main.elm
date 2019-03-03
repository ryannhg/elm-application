module Main exposing (main)

import Application
import Pages.About
import Pages.Home
import Url.Parser as Parser


type Msg
    = HomeMsg Pages.Home.Msg
    | AboutMsg Pages.About.Msg


main : Application Flags Model Msg
main =
    Application.program
        { routes =
            [ Parser.map
                (Pages.Home.route HomeMsg)
                Parser.top
            , Parser.map
                (Pages.About.route AboutMsg)
                (Parser.s "about")
            ]
        }
