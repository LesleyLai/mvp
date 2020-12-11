module MVP.Interpreter exposing (Semantics(..), step)

import MVP.AST.Runnable as AST exposing (Expr(..), isValue)
import MVP.Data.Builtins exposing (BinaryOp(..))
import MVP.Data.Identifier exposing (Identifier)


type Semantics
    = NoSemantics
    | AppApply
    | AppStepArg
    | AppStepFunc



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


type alias StepResult =
    { expr : Expr
    , semantics : Semantics
    }


step : Expr -> StepResult
step expr =
    case expr of
        Bool _ ->
            { expr = expr, semantics = NoSemantics }

        Int _ ->
            { expr = expr, semantics = NoSemantics }

        Unit ->
            { expr = expr, semantics = NoSemantics }

        Lambda _ ->
            { expr = expr, semantics = NoSemantics }

        Var identifier ->
            -- Runtime type error: should never happen
            { expr = Var identifier, semantics = NoSemantics }

        App { func, arg } ->
            case func of
                Lambda { body, param } ->
                    if isValue arg then
                        { expr = subst arg param body, semantics = AppApply }

                    else
                        { expr = App { func = func, arg = (step arg).expr }, semantics = AppStepArg }

                _ ->
                    { expr = App { func = (step func).expr, arg = arg }, semantics = AppStepFunc }

        BinaryOp op lhs rhs ->
            if isValue lhs && isValue rhs then
                case ( op, lhs, rhs ) of
                    ( Plus, Int x, Int y ) ->
                        { expr = Int (x + y), semantics = AppApply }

                    ( Minus, Int x, Int y ) ->
                        { expr = Int (x - y), semantics = AppApply }

                    ( Multiplies, Int x, Int y ) ->
                        { expr = Int (x * y), semantics = AppApply }

                    ( Divides, Int x, Int y ) ->
                        { expr = Int (x // y), semantics = AppApply }

                    _ ->
                        -- Runtime type error: should never happen
                        { expr = BinaryOp op lhs rhs, semantics = NoSemantics }

            else if isValue lhs then
                { expr = BinaryOp op lhs (step rhs).expr, semantics = AppStepArg }

            else
                { expr = BinaryOp op (step lhs).expr rhs, semantics = AppStepArg }
