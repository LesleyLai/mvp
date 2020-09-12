module MVP.Interpreter exposing (step)

import MVP.AST.Runnable as AST exposing (Expr(..), isValue)
import MVP.Identifier exposing (Identifier)



-- A substitution-based interpreter


isValue : Expr -> Bool
isValue e =
    AST.isValue e



-- [e'/x]e


subst : Expr -> Identifier -> Expr -> Expr
subst expr_ x expr =
    case expr of
        Bool _ ->
            expr

        Int _ ->
            expr

        Unit ->
            expr

        Var y ->
            if x == y then
                expr_

            else
                Var y

        Lambda { param, body } ->
            if param == x then
                expr
                -- Shadowing

            else
                Lambda { param = param, body = subst expr_ x body }

        App { func, arg } ->
            App { func = subst expr_ x func, arg = subst expr_ x arg }

        Plus lhs rhs ->
            Plus (subst expr_ x lhs) (subst expr_ x rhs)


step : Expr -> Expr
step expr =
    case expr of
        Bool _ ->
            expr

        Int _ ->
            expr

        Unit ->
            expr

        Lambda _ ->
            expr

        Var identifier ->
            if identifier == "+" then
                Lambda
                    { body = Lambda { body = Plus (Var "lhs") (Var "rhs"), param = "rhs" }
                    , param = "lhs"
                    }

            else
                Var identifier
                -- Debug.todo ("Unrecognized identifier " ++ identifier)

        App { func, arg } ->
            case func of
                Lambda { body, param } ->
                    if isValue arg then
                        subst arg param body

                    else
                        App { func = func, arg = step arg }

                _ ->
                    App { func = step func, arg = arg }

        Plus (Int x) (Int y) ->
            Int (x + y)

        Plus (Int x) y ->
            Plus (Int x) (step y)

        Plus x y ->
            Plus (step x) y
