module MVP.Visualizer.AST exposing (drawAST)

import Html exposing (Html)
import MVP.AST.Runnable exposing (Expr(..), isValue)
import MVP.Data.Identifier exposing (Identifier)
import Svg exposing (Svg, g, line, rect, svg, text, text_)
import Svg.Attributes exposing (..)
import TreeDiagram exposing (Tree, topToBottom, node)
import TreeDiagram.Svg exposing (draw)


type FoundActive
    = FoundActive
    | NotFoundActive


type alias Color =
    String


visualizeAppAst : Expr -> Expr -> FoundActive -> Tree ( String, Color )
visualizeAppAst func arg foundActive =
    case foundActive of
        NotFoundActive ->
            case func of
                Lambda _ ->
                    if isValue arg then
                        node ( "App", activeBg )
                            [ visualizeAst func FoundActive
                            , visualizeAst arg FoundActive
                            ]

                    else
                        node ( "App", defaultBg )
                            [ visualizeAst func FoundActive
                            , visualizeAst arg NotFoundActive
                            ]

                _ ->
                    node ( "App", defaultBg )
                        [ visualizeAst func NotFoundActive
                        , visualizeAst arg FoundActive
                        ]

        _ ->
            node ( "App", defaultBg )
                [ visualizeAst func foundActive
                , visualizeAst arg foundActive
                ]


visualizeVarAst : Identifier -> FoundActive -> Tree ( String, Color )
visualizeVarAst id foundActive =
    let
        bg =
            case foundActive of
                FoundActive ->
                    defaultBg

                NotFoundActive ->
                    activeBg
    in
    node ( "'" ++ id, bg ) []


visualizePlusAst : Expr -> Expr -> FoundActive -> Tree ( String, Color )
visualizePlusAst lhs rhs foundActive =
    case foundActive of
        NotFoundActive ->
            case ( lhs, rhs ) of
                ( Int _, Int _ ) ->
                    node ( "+", activeBg )
                        [ visualizeAst lhs FoundActive, visualizeAst rhs FoundActive ]

                ( _, Int _ ) ->
                    node ( "+", defaultBg )
                        [ visualizeAst lhs NotFoundActive, visualizeAst rhs FoundActive ]

                ( _, _ ) ->
                    node ( "+", defaultBg )
                        [ visualizeAst lhs FoundActive, visualizeAst rhs NotFoundActive ]

        _ ->
            node ( "+", defaultBg )
                [ visualizeAst lhs foundActive, visualizeAst rhs foundActive ]

defaultBg: Color
defaultBg =
    "#128277"

activeBg: Color
activeBg =
    "#12bb77"


visualizeAst : Expr -> FoundActive -> Tree ( String, Color )
visualizeAst expr foundActive =
    case expr of
        Bool True ->
            node ( "True", defaultBg ) []

        Bool False ->
            node ( "False", defaultBg ) []

        Int i ->
            node ( String.fromInt i, defaultBg ) []

        Unit ->
            node ( "Unit", defaultBg ) []

        Var x ->
            visualizeVarAst x foundActive

        Lambda { param, body } ->
            node ( "Lambda", defaultBg )
                [ visualizeAst (Var param) FoundActive
                , visualizeAst body FoundActive
                ]

        App { func, arg } ->
            visualizeAppAst func arg foundActive

        Plus lhs rhs ->
            visualizePlusAst lhs rhs foundActive


drawLine : ( Float, Float ) -> Svg msg
drawLine ( targetX, targetY ) =
    line
        [ x1 "0", y1 "0", x2 (String.fromFloat targetX), y2 (String.fromFloat targetY), stroke "black" ]
        []


{-| Represent nodes as circles with the node value inside.
-}
drawNode : ( String, String ) -> Svg msg
drawNode ( content, bg ) =
    g
        []
        [ rect [ rx "15", ry "15", x "-40", y "-15", height "30", width "80", stroke "black", fill bg ] []
        , text_ [ textAnchor "middle", transform "translate(0,5)", fill "#ffffff" ] [ text content ]
        ]


drawAST : Maybe Expr -> Html msg
drawAST maybeExpr =
    case maybeExpr of
        Just expr ->
            draw
                { orientation = topToBottom
                , levelHeight = 40
                , siblingDistance = 100
                , subtreeDistance = 80
                , padding = 40
                }
                drawNode
                drawLine
                (visualizeAst expr NotFoundActive)

        Nothing ->
            svg [] []
