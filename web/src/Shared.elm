module Shared exposing
    ( Flags
    , Model
    , Msg
    , difficulties
    , init
    , statuses
    , subscriptions
    , tags
    , update
    , view
    )

import Api exposing (AuthError, AuthSuccess)
import Api.Config as Config exposing (Config)
import Browser.Navigation exposing (Key)
import Html exposing (..)
import Html.Attributes exposing (class, href)
import Html.Events exposing (onClick)
import Json.Encode as Encode
import Role exposing (Role(..))
import Session exposing (Session)
import Spa.Document exposing (Document)
import Spa.Generated.Route as Route
import Url exposing (Url)
import Viewer exposing (Viewer)



-- INIT


type alias Model =
    { url : Url
    , key : Key
    , session : Session
    , config : Config
    , role : Role
    , authMessage : String
    }


type alias Flags =
    { maybeConfig : Maybe Config
    , maybeViewer : Maybe Viewer
    }


init : Flags -> Url -> Key -> ( Model, Cmd Msg )
init flags url key =
    let
        session =
            Session.fromViewer flags.maybeViewer

        config =
            Config.init flags.maybeConfig
    in
    ( Model url key session config Student ""
    , Cmd.none
    )



-- UPDATE


type Msg
    = Login
    | Logout
    | GotAuthResult (Result AuthError AuthSuccess)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Login ->
            ( model, login )

        Logout ->
            ( model, logout )

        GotAuthResult (Ok authSuccess) ->
            ( { model | authMessage = Api.authSuccessMessage authSuccess }, Cmd.none )

        GotAuthResult (Err authError) ->
            ( { model | authMessage = Api.authErrorMessage authError }, Cmd.none )

        GotSession session ->
            let
                dbg =
                    Debug.log "session" session
            in
            ( { model
                | session = session
              }
            , case model.role of
                Student ->
                    Browser.Navigation.replaceUrl model.key (Route.toString Route.Profile__Student)

                Instructor ->
                    Browser.Navigation.replaceUrl model.key (Route.toString Route.ProtectedApplicationTemplate)
            )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Session.changes GotSession
        , Api.authResult (\authMessage -> GotAuthResult authMessage)
        ]



-- VIEW


view :
    { page : Document msg, toMsg : Msg -> msg }
    -> Model
    -> Document msg
view { page, toMsg } model =
    { title = page.title
    , body =
        [ div [ class "layout" ]
            [ div [ class "page" ] page.body
            , header [ class "navbar" ]
                [ a [ class "link", href (Route.toString Route.Top) ] [ text "Homepage" ]
                , a [ class "link", href (Route.toString Route.NotFound) ] [ text "Not found" ]
                , a [ class "link", href (Route.toString Route.About) ] [ text "About" ]
                , a [ class "link", href (Route.toString Route.Acknowledgments) ] [ text "Acknowledgments" ]
                , a [ class "link", href (Route.toString Route.ProtectedApplicationTemplate) ] [ text "Protected" ]
                ]
            , div []
                [ div []
                    [ text ("Token: " ++ Api.exposeToken (Session.cred model.session)) ]
                , div [] [ text ("REST API URL: " ++ Config.restApiUrl model.config) ]
                , button [ onClick (toMsg Login) ] [ text "Login" ]
                , button [ onClick (toMsg Logout) ] [ text "Logout" ]
                , div [] [ text ("Auth Message: " ++ model.authMessage) ]
                ]
            ]
        ]
    }



-- AUTH


login : Cmd msg
login =
    let
        creds =
            Encode.object
                [ ( "username", Encode.string "test@email.com" )
                , ( "password", Encode.string "password" )
                ]
    in
    Api.login creds


logout : Cmd msg
logout =
    Api.logout ()



-- DATA


difficulties : List ( String, String )
difficulties =
    [ ( "intermediate_mid", "Intermediate-Mid" )
    , ( "intermediate_high", "Intermediate-High" )
    , ( "advanced_low", "Advanced-Low" )
    , ( "advanced_mid", "Advanced-Mid" )
    ]


tags : List String
tags =
    [ "Culture"
    , "Music"
    , "Film"
    , "Literary Arts"
    , "Visual Arts"
    , "Sports"
    , "Internal Affairs"
    , "History"
    , "Biography"
    , "News Briefs"
    , "Economics/Business"
    , "Medicine/Health Care"
    , "Science/Technology"
    , "Human Interest"
    , "Society and Societal Trends"
    , "International Relations"
    , "Public Policy"
    , "Other"
    , "Kazakhstan"
    ]


statuses : List ( String, String )
statuses =
    [ ( "unread", "Unread" )
    , ( "in_progress", "In Progress" )
    , ( "read", "Read" )
    ]
