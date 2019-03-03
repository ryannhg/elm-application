module Pages.Home exposing (route, Msg)

type alias Model = Maybe Int

type Msg =
    SetNumber Int

type alias Route appMsg =
    { 
    }

route : (Msg -> a) -> (Route a)
route toMsg =
