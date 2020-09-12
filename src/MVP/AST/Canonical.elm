module MVP.AST.Canonical exposing (Expr(..), toString)

import MVP.Data.Identifier exposing (Identifier)

{-
   Canonical AST reflects the "official definition" of the MVP AST
-}


type Expr
    = Bool Bool
    | Int Int
    | Unit
    | Var Identifier
    | Lambda Identifier Expr -- param body
    | App Expr Expr -- func arg

toString : Expr -> String
toString e =
    case e of
        Bool True ->
            "True"

        Bool False ->
            "False"

        Int i ->
            String.fromInt i

        Unit ->
            "unit"

        Lambda param body ->
            "(lambda (" ++ param ++ ") " ++ toString body ++ ")"

        Var id ->
            id

        App func arg ->
            "(" ++ toString func ++ " " ++ toString arg ++ ")"
