module MVP.AST.Runnable exposing
    ( Expr(..)
    , fromCanonical
    , isValue
    , toString
    )

import MVP.AST.Canonical as Canonical
import MVP.Identifier exposing (Identifier)



{-
   Runnable AST is what get used at runtime
-}

type Expr
    = Bool Bool
    | Int Int
    | Unit
    | Var Identifier
    | Lambda { param : Identifier, body : Expr }
    | App { func : Expr, arg : Expr }
    | Plus Expr Expr


fromCanonical : Canonical.Expr -> Expr
fromCanonical e =
    case e of
        Canonical.Bool b ->
            Bool b

        Canonical.Int i ->
            Int i

        Canonical.Unit ->
            Unit

        Canonical.Var id ->
            Var id

        Canonical.Lambda { param, body } ->
            Lambda { param = param, body = fromCanonical body }

        Canonical.App { func, arg } ->
            App { func = fromCanonical func, arg = fromCanonical arg }


isValue : Expr -> Bool
isValue e =
    case e of
        Bool _ ->
            True

        Int _ ->
            True

        Unit ->
            True

        Lambda _ ->
            True

        _ -> False


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

        Lambda { param, body } ->
            "(lambda (" ++ param ++ ") " ++ toString body ++ ")"

        Var id ->
            id

        App { func, arg } ->
            "(" ++ toString func ++ " " ++ toString arg ++ ")"

        Plus lhs rhs ->
            "(+ " ++ toString lhs ++ " " ++ toString rhs ++ ")"
