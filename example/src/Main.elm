module Main exposing (Model)

import Application
import Application.Page exposing (static)
import Global
import Html exposing (Html)
import Pages.Home
import Pages.NotFound
import Url exposing (Url)
import Url.Parser as Parser


type Msg
    = HomeMsg Pages.Home.Msg
    | NotFoundMsg Pages.NotFound.Msg


type Model
    = NotLoaded
    | Home Pages.Home.Model
    | NotFound Pages.NotFound.Model



-- main =
--     Html.text "Hello"
-- MAIN
-- { routes : List (Routes userFlags userModel userMsg)
-- , notFound : Page userFlags userModel userMsg
-- , init : UserInitFunction userFlags userModel userMsg
-- , update : UserUpdateFunction userModel userMsg
-- , subscriptions : UserSubscriptionsFunction userModel userMsg
-- }


main =
    Application.program
        { routes =
            [ Parser.map
                (static Home HomeMsg Pages.Home.page)
                Parser.top
            ]
        , notFound =
            static NotFound NotFoundMsg Pages.NotFound.page
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Url -> Global.Flags -> ( Model, Cmd Msg )
init url flags =
    ( NotLoaded, Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
