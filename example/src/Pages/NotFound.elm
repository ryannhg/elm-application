module Pages.NotFound exposing (Model, Msg, page)

import Application.Page exposing (Document, StaticPage)
import Global
import Html exposing (Html)
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
    { title = "Not found"
    , body = [ Html.text "Not found" ]
    }
