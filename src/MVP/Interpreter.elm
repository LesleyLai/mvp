module MVP.Interpreter exposing (step)

import MVP.AST.Runnable as AST exposing (Expr(..), isValue)
import MVP.Data.Identifier exposing (Identifier)
import MVP.Data.Builtins exposing (BinaryOp(..))

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

        BinaryOp op lhs rhs ->
            BinaryOp op (subst expr_ x lhs) (subst expr_ x rhs)


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
            Var identifier -- Runtime type error: should never happen

        App { func, arg } ->
            case func of
                Lambda { body, param } ->
                    if isValue arg then
                        subst arg param body

                    else
                        App { func = func, arg = step arg }

                _ ->
                    App { func = step func, arg = arg }

        BinaryOp op lhs rhs ->
            if isValue lhs && isValue rhs then
                case (op, lhs, rhs) of
                    (Plus, Int x, Int y) ->
                        Int (x + y)
                    (Minus, Int x, Int y) ->
                        Int (x - y)
                    (Multiplies, Int x, Int y) ->
                        Int (x * y)
                    (Divides, Int x, Int y) ->
                        Int (x // y)
                    _ -> BinaryOp op lhs rhs -- Runtime type error: should never happen
            else if isValue lhs then
                BinaryOp op lhs (step rhs)
            else
                BinaryOp op (step lhs) rhs