module Pages.Counter exposing (Model, Msg, page)

import Application.Page exposing (Document, SandboxPage)
import Global
import Html exposing (..)
import Html.Attributes exposing (href)
import Html.Events exposing (onClick)
import Url exposing (Url)


type Msg
    = Increment
    | Decrement


type alias Model =
    Int


page : SandboxPage Global.Flags Model Msg
page =
    { init = init
    , view = view
    , update = update
    }


init : Url -> Global.Flags -> Model
init _ _ =
    0


view : Model -> Document Msg
view model =
    { title = "Counter"
    , body =
        [ div []
            [ h1 [] [ text "Counter" ]
            , a [ href "/" ] [ text "Homepage" ]
            , h3 [] [ text (String.fromInt model) ]
            , button [ onClick Increment ] [ text "+" ]
            , button [ onClick Decrement ] [ text "-" ]
            ]
        ]
    }


update : Msg -> Model -> Model
update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            model - 1
