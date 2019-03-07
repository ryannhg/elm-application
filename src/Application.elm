module Application exposing (program)

import Application.Page exposing (Page)
import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type alias Model userFlags userModel =
    { url : Url
    , key : Nav.Key
    , flags : userFlags
    , userModel : userModel
    }


type Msg userMsg
    = UserMsg userMsg
    | UrlChanged Url
    | UrlRequested UrlRequest


type alias UrlParser a =
    Parser (a -> a) a


type alias Routes userFlags userModel userMsg =
    UrlParser (Page userFlags userModel userMsg)


type alias Configuration userFlags userModel userMsg =
    { routes : List (Routes userFlags userModel userMsg)
    , notFound : Page userFlags userModel userMsg
    , init : UserInitFunction userFlags userModel userMsg
    , update : UserUpdateFunction userModel userMsg
    , subscriptions : UserSubscriptionsFunction userModel userMsg
    }


program :
    Configuration userFlags userModel userMsg
    -> Program userFlags (Model userFlags userModel) (Msg userMsg)
program config =
    Browser.application
        { init = init config.routes config.notFound config.init
        , update = update config.routes config.notFound config.init config.update
        , view = view config.routes config.notFound
        , subscriptions = subscriptions config.subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- INIT
-- TODO: User might want Url too, but skipping for now


type alias UserInitFunction userFlags userModel userMsg =
    Url -> userFlags -> ( userModel, Cmd userMsg )


init :
    List (Routes userFlags userModel userMsg)
    -> Page userFlags userModel userMsg
    -> UserInitFunction userFlags userModel userMsg
    -> userFlags
    -> Url
    -> Nav.Key
    -> ( Model userFlags userModel, Cmd (Msg userMsg) )
init routes notFoundPage userInit flags url key =
    let
        ( userModel, userCmd ) =
            userInit url flags

        ( loadedUserModel, otherUserCmd ) =
            findPage routes url notFoundPage
                |> .init
                |> (\f -> f userModel url flags)
    in
    ( Model url key flags loadedUserModel
    , Cmd.batch <|
        List.map
            (Cmd.map UserMsg)
            [ userCmd, otherUserCmd ]
    )



-- UPDATE


type alias UserUpdateFunction userModel userMsg =
    userMsg -> userModel -> ( userModel, Cmd userMsg )


update :
    List (Routes userFlags userModel userMsg)
    -> Page userFlags userModel userMsg
    -> UserInitFunction userFlags userModel userMsg
    -> UserUpdateFunction userModel userMsg
    -> Msg userMsg
    -> Model userFlags userModel
    -> ( Model userFlags userModel, Cmd (Msg userMsg) )
update routes notFoundPage userInit userUpdate msg model =
    case msg of
        UrlChanged url ->
            let
                ( userModel, userCmd ) =
                    findPage routes url notFoundPage
                        |> .init
                        |> (\f -> f model.userModel url model.flags)
            in
            ( { model | userModel = userModel, url = url }
            , Cmd.map UserMsg userCmd
            )

        UrlRequested urlRequest ->
            case urlRequest of
                Internal url ->
                    ( model
                    , Nav.pushUrl model.key (Url.toString url)
                    )

                External url ->
                    ( model
                    , Nav.load url
                    )

        UserMsg userMsg ->
            let
                ( userModel, userCmd ) =
                    userUpdate userMsg model.userModel
            in
            ( { model | userModel = userModel }
            , Cmd.map UserMsg userCmd
            )


type alias Document msg =
    { title : String
    , body : List (Html msg)
    }



-- VIEW


findPage :
    List (Routes userFlags userModel userMsg)
    -> Url
    -> Page userFlags userModel userMsg
    -> Page userFlags userModel userMsg
findPage routes url notFoundPage =
    Parser.parse (Parser.oneOf routes) url
        |> Maybe.withDefault notFoundPage


view :
    List (Routes userFlags userModel userMsg)
    -> Page userFlags userModel userMsg
    -> Model userFlags userModel
    -> Document (Msg userMsg)
view routes notFoundPage model =
    let
        page =
            findPage routes model.url notFoundPage

        { title, body } =
            page.view model.url model.flags model.userModel
    in
    { title = title
    , body = List.map (Html.map UserMsg) body
    }



-- SUBSCRIPTIONS


type alias UserSubscriptionsFunction userModel userMsg =
    userModel -> Sub userMsg


subscriptions : UserSubscriptionsFunction userModel userMsg -> Model userFlags userModel -> Sub (Msg userMsg)
subscriptions userSubscriptions model =
    Sub.map UserMsg (userSubscriptions model.userModel)
