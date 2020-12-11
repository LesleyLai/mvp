module Main exposing (main)

import Browser
import Html exposing (Attribute, Html, button, div, h1, h2, h3, node, p, text)
import Html.Attributes exposing (attribute, disabled, style)
import Html.Events
import Json.Decode
import MVP.AST.Runnable as Runnable exposing (isValue)
import MVP.Interpreter exposing (Semantics(..))
import MVP.Parse
import MVP.UI.MarkdownView exposing (markdownView)
import MVP.Visualizer.AST exposing (drawAST)
import Parser



---- MODEL ----


type alias Model =
    { source : String
    , astHistory : List Runnable.Expr
    , errorMsg : Maybe String
    , semanticsHistory : List Semantics
    }


init : ( Model, Cmd Msg )
init =
    ( { source = "", astHistory = [], errorMsg = Nothing, semanticsHistory = [] }, Cmd.none )



---- UPDATE ----


type Msg
    = SourceChange String
    | SendSource
    | Step
    | StepBack
    | Execute


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SourceChange newSource ->
            ( { model | source = newSource }, Cmd.none )

        SendSource ->
            case
                model.source
                    |> MVP.Parse.parse
                    |> Result.map Runnable.fromCanonical
            of
                Ok newAst ->
                    ( { model | astHistory = [ newAst ], errorMsg = Nothing }, Cmd.none )

                Err errors ->
                    ( { model
                        | errorMsg =
                            Just ("Syntax Error: " ++ Parser.deadEndsToString errors)
                      }
                    , Cmd.none
                    )

        Step ->
            case model.astHistory of
                ast :: _ ->
                    let
                        stepResult =
                            MVP.Interpreter.step ast
                    in
                    let
                        newAst =
                            stepResult.expr
                    in
                    ( { model
                        | astHistory = newAst :: model.astHistory
                        , semanticsHistory = stepResult.semantics :: model.semanticsHistory
                        , errorMsg = Nothing
                      }
                    , Cmd.none
                    )

                [] ->
                    ( model, Cmd.none )

        StepBack ->
            ( { model
                | astHistory = model.astHistory |> List.tail |> Maybe.withDefault []
                , semanticsHistory = model.semanticsHistory |> List.tail |> Maybe.withDefault []
                , errorMsg = Nothing
              }
            , Cmd.none
            )

        Execute ->
            ( model, Cmd.none )



-- let
--     execute astHistory =
--         case astHistory of
--             [] ->
--                 []
--             ast :: _ ->
--                 if isValue ast then
--                     astHistory
--                 else
--                     execute (MVP.Interpreter.step ast :: astHistory)
-- in
-- ( { model | astHistory = execute model.astHistory, errorMsg = Nothing }, Cmd.none )
---- VIEW ----


onSourceChange : Attribute Msg
onSourceChange =
    Json.Decode.at [ "detail", "source" ] Json.Decode.string
        |> Json.Decode.map SourceChange
        |> Html.Events.on "source-change"


codeEditor : List (Attribute msg) -> List (Html msg) -> Html msg
codeEditor =
    node "code-editor"


latexFileNameOfSemantics : Semantics -> String
latexFileNameOfSemantics semantics =
    case semantics of
        NoSemantics ->
            ""

        AppApply ->
            "app-step-apply.md"

        AppStepArg ->
            "app-step-arg.md"

        AppStepFunc ->
            "app-step-func.md"


view : Model -> Html Msg
view model =
    let
        ( cannotContinue, cannotStepBack, currentAst ) =
            case model.astHistory of
                [] ->
                    ( True, True, Nothing )

                head :: [] ->
                    ( Runnable.isValue head, True, Just head )

                head :: _ ->
                    ( Runnable.isValue head, False, Just head )

        previousStepSemanticsFileName =
            model.semanticsHistory
                |> List.head
                |> Maybe.map latexFileNameOfSemantics
                |> Maybe.withDefault ""
    in
    div []
        [ h1 [] [ text "MVP Interpreter" ]
        , h2 [] [ text "Minimal Visual Pedagogical Interpreter" ]
        , codeEditor
            [ attribute "source" model.source
            , onSourceChange
            ]
            []
        , div []
            [ button [ Html.Events.onClick SendSource ] [ text "Send source" ]
            , button [ disabled True, Html.Events.onClick Execute ] [ text "Execute" ]
            , button [ disabled cannotContinue, Html.Events.onClick Step ] [ text "Step Forward" ]
            , button [ disabled cannotStepBack, Html.Events.onClick StepBack ] [ text "Step Backward" ]
            ]
        , drawAST currentAst
        , p [ style "color" "red" ]
            [ text
                (model.errorMsg |> Maybe.withDefault "")
            ]
        , h3 [] [ text "Small step semantics of the previous step" ]
        , markdownView previousStepSemanticsFileName
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
