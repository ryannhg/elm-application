module Application.Page exposing
    (  Document
       -- , DocumentPage

    , Page
    , SandboxPage
    ,  StaticPage
       -- , document

    , sandbox
    , static
    , updateSandbox
    )

import Html exposing (Html)
import Url exposing (Url)


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }


type alias Page flags model msg =
    { init : model -> Url -> flags -> ( model, Cmd msg )
    , view : Url -> flags -> model -> Document msg
    }


noInit : model -> Url -> flags -> ( model, Cmd msg )
noInit model url flags =
    ( model, Cmd.none )



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
        (\url flags model ->
            let
                { title, body } =
                    page.view url flags
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
        )



-- SANDBOX


type alias SandboxPage flags model msg =
    { init : Url -> flags -> model
    , view : model -> Document msg
    , update : msg -> model -> model
    }


sandbox :
    (model -> userModel)
    -> (msg -> userMsg)
    -> (userModel -> Maybe model)
    -> SandboxPage flags model msg
    -> Page flags userModel userMsg
sandbox toModel toMsg getModelFrom page =
    Page
        (\userModel url flags ->
            upgrade toModel toMsg ( page.init url flags, Cmd.none )
        )
        (\url flags userModel ->
            case getModelFrom userModel of
                Just model ->
                    let
                        { title, body } =
                            page.view model
                    in
                    { title = title
                    , body = List.map (Html.map toMsg) body
                    }

                Nothing ->
                    { title = ""
                    , body = []
                    }
        )


updateSandbox :
    (model -> userModel)
    -> (msg -> userMsg)
    -> msg
    -> model
    -> SandboxPage flags model msg
    -> ( userModel, Cmd userMsg )
updateSandbox toModel toMsg msg model page =
    upgrade
        toModel
        toMsg
        (page.update msg model, Cmd.none )


upgrade :
    (model -> userModel)
    -> (msg -> userMsg)
    -> ( model, Cmd msg )
    -> ( userModel, Cmd userMsg )
upgrade toModel toMsg ( model, cmd ) =
    ( toModel model
    , Cmd.map toMsg cmd
    )



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
