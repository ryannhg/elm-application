module Pages.Home exposing (Model, Msg, page)

import Application.Page exposing (Document, StaticPage)
import Global
import Html exposing (..)
import Html.Attributes exposing (href)
import Url exposing (Url)


type Msg
    = NoOp


type alias Model =
    ()


page : StaticPage Global.Flags Msg
page =
    { view = view
    }


view : Url -> Global.Flags -> Document Msg
view url flags =
    { title = "Homepage"
    , body = 
    [ 
        div [] 
        [ h1 [] [ text "Home" ] 

        , a [ href "/counter" ] [ text "Counter" ]
        ]
    ]
    }
