module Application exposing (program)

import Browser exposing (UrlRequest(..))
import Browser.Navigation as Nav
import Html exposing (Html)
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser)


type alias Model userModel =
    { url : Url
    , key : Nav.Key
    , userModel : userModel
    }


type Msg userMsg
    = UserMsg userMsg
    | UrlChanged Url
    | UrlRequested UrlRequest


type alias Routes userModel userMsg =
    Parser (UserView userModel userMsg -> UserView userModel userMsg) (UserView userModel userMsg)


type Configuration userFlags userModel userMsg
    = Configuration
        { routes : List (Routes userModel userMsg)
        , notFound : UserView userModel userMsg
        , init : UserInitFunction userFlags userModel userMsg
        , update : UserUpdateFunction userModel userMsg
        , subscriptions : UserSubscriptionsFunction userModel userMsg
        }


program :
    Configuration userFlags userModel userMsg
    -> Program userFlags (Model userModel) (Msg userMsg)
program (Configuration config) =
    Browser.application
        { init = init config.init
        , update = update config.update
        , view = view config.notFound config.routes
        , subscriptions = subscriptions config.subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        }



-- INIT
-- TODO: User might want Url to, but skipping for now


type alias UserInitFunction userFlags userModel userMsg =
    userFlags -> ( userModel, Cmd userMsg )


init : UserInitFunction userFlags userModel userMsg -> userFlags -> Url -> Nav.Key -> ( Model userModel, Cmd (Msg userMsg) )
init userInit flags url key =
    let
        ( userModel, userCmd ) =
            userInit flags
    in
    ( Model url key userModel
    , Cmd.map UserMsg userCmd
    )



-- UPDATE


type alias UserUpdateFunction userModel userMsg =
    userMsg -> userModel -> ( userModel, Cmd userMsg )


update : UserUpdateFunction userModel userMsg -> Msg userMsg -> Model userModel -> ( Model userModel, Cmd (Msg userMsg) )
update userUpdate msg model =
    case msg of
        UrlChanged url ->
            ( { model | url = url }, Cmd.none )

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


type alias PageView msg =
    { title : String
    , html : Html msg
    }



-- VIEW


type alias UserView userModel userMsg =
    userModel -> PageView userMsg


routesToView :
    UserView userModel userMsg
    -> List (Routes userModel userMsg)
    -> Url
    -> UserView userModel userMsg
routesToView notFoundView routes url =
    Parser.parse (Parser.oneOf routes) url
        |> Maybe.withDefault notFoundView


view :
    UserView userModel userMsg
    -> List (Routes userModel userMsg)
    -> Model userModel
    -> Document (Msg userMsg)
view notFoundView routes model =
    let
        { title, html } =
            routesToView
                notFoundView
                routes
                model.url
                model.userModel
    in
    { title = title
    , body =
        [ Html.map
            UserMsg
            html
        ]
    }



-- SUBSCRIPTIONS


type alias UserSubscriptionsFunction userModel userMsg =
    userModel -> Sub userMsg


subscriptions : UserSubscriptionsFunction userModel userMsg -> Model userModel -> Sub (Msg userMsg)
subscriptions userSubscriptions model =
    Sub.map UserMsg (userSubscriptions model.userModel)
