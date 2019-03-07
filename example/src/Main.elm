module Main exposing (Model)

import Application
import Application.Page exposing (sandbox, static)
import Global
import Html exposing (Html)
import Pages.Counter
import Pages.Home
import Pages.NotFound
import Url exposing (Url)
import Url.Parser as Parser


type Msg
    = NoOp
    | CounterMsg Pages.Counter.Msg


type Model
    = Empty ()
    | Counter Pages.Counter.Model

static =
    Application.Page.static Empty (always NoOp)

-- MAIN


main =
    Application.program
        { routes =
            [ Parser.map (static Pages.Home.page) Parser.top
            , Parser.map
                (sandbox Counter CounterMsg
                    -- TODO, view case expression should be external...
                    (\model ->
                        case model of
                            Counter inner ->
                                Just inner

                            _ ->
                                Nothing
                    )
                    Pages.Counter.page
                )
                (Parser.s "counter")
            ]
        , notFound = static Pages.NotFound.page
        , init = init
        , update = update
        , subscriptions = subscriptions
        }


init : Url -> Global.Flags -> ( Model, Cmd Msg )
init url flags =
    ( Empty (), Cmd.none )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg_ model_ =
    case ( msg_, model_ ) of
        -- Static pages 
        ( NoOp, _ ) ->
            ( model_, Cmd.none )

        -- Counter
        ( CounterMsg msg, Counter model ) ->
            Application.Page.updateSandbox
                Counter
                CounterMsg
                msg
                model
                Pages.Counter.page

        ( CounterMsg _, _ ) ->
            ( model_, Cmd.none )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
