module Application.Page exposing
    (  Document
       -- , DocumentPage

    ,  Page
       -- , SandboxPage

    ,  StaticPage
       -- , document
       -- , sandbox

    , static
    )

import Html exposing (Html)
import Url exposing (Url)


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


type alias Page flags model msg =
    { init : model -> Url -> flags -> ( model, Cmd msg )
    , update : msg -> model -> ( model, Cmd msg )
    , view : Url -> flags -> model -> Document msg
    , subscriptions : model -> Sub msg
    }


noInit : model -> Url -> flags -> ( model, Cmd msg )
noInit model url flags =
    ( model, Cmd.none )


noUpdate : msg -> model -> ( model, Cmd msg )
noUpdate msg model =
    ( model, Cmd.none )


noSubscriptions : model -> Sub msg
noSubscriptions model =
    Sub.none



-- STATIC


type alias StaticPage flags msg =
    { view : Url -> flags -> Document msg
    }


static :
    (model -> userModel)
    -> (msg -> userMsg)
    -> StaticPage flags msg
    -> Page flags userModel userMsg
static toModel toMsg page =
    Page
        noInit
        noUpdate
        (\url flags model ->
            let
                { title, body } =
                    page.view url flags
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
        )
        noSubscriptions



-- -- SANDBOX
-- type alias SandboxPage flags model msg =
--     { init : Url -> flags -> model
--     , view : model -> Document msg
--     , update : msg -> model -> model
--     }
-- sandbox :
--     (model -> userModel)
--     -> (msg -> userMsg)
--     -> SandboxPage flags model msg
--     -> Page flags userModel userMsg
-- sandbox toModel toMsg page =
--     Page
--         (PageConfig
--             (\url flags -> ( page.init url flags, Cmd.none ))
--             noUpdate
--             (\url flags model -> page.view model)
--             noSubscriptions
--         )
-- -- DOCUMENT
-- type alias DocumentPage flags model msg =
--     { init : Url -> flags -> ( model, Cmd msg )
--     , view : model -> Document msg
--     , update : msg -> model -> ( model, Cmd msg )
--     , subscriptions : model -> Sub msg
--     }
-- document :
--     (model -> userModel)
--     -> (msg -> userMsg)
--     -> DocumentPage flags model msg
--     -> Page flags userModel userMsg
-- document toModel toMsg page =
--     Page
--         (PageConfig
--             (\url flags ->
--                 let
--                     ( model, cmd ) =
--                         page.init url flags
--                 in
--                 ( toModel model
--                 , Cmd.map toMsg cmd
--                 )
--             )
--             noUpdate
--             (\url flags model -> page.view model)
--             noSubscriptions
--         )
