module MVP.Unify exposing (..)

import MVP.Data.Identifier exposing (Identifier)
import MVP.Types exposing (Type(..))

-- Invariant for substitutions: no id on a lhs occurs in any term earlier
type alias Substitution = List (Identifier, Type)

-- Checks if a variable occurs in a type t
occurs : Identifier -> Type -> Bool
occurs x t =
    case t of
        TVar y -> x == y
        TArrow u v -> occurs x u || occurs x v

-- Substitute type s for all occurrences of var x in type t
subst : Type -> Identifier -> Type -> Type
subst s x t =
    case t of
       TVar y -> if x == y then s else t
       TArrow u v -> TArrow (subst s x u) (subst s x v)

-- apply a substitution to t right to left
apply : Substitution -> Type -> Type
apply s t =
    List.foldr (\ (x, e) -> subst e x) t s

unifyTVarArrow : Identifier -> Type -> Result String Substitution
unifyTVarArrow x tArrow =
    if occurs x tArrow then
        Err "not unifiable: circularity"
    else
        Ok [(x, tArrow)]

-- Tries to unify two types
unifyOne : Type -> Type -> Result String Substitution
unifyOne s t =
    case (s, t) of
        (TVar x, TVar y) -> Ok <| if x == y then [] else [(x, t)]
        (TArrow t1 t2, TArrow t3 t4) -> unify [(t1, t3), (t2, t4)]
        (TVar x, TArrow _ _ as t2)  ->
            unifyTVarArrow x t2
        (TArrow _ _ as t2, TVar x)  ->
            unifyTVarArrow x t2

-- Tries to unify a list of pairs
unify : List (Type, Type) -> Result String Substitution
unify s =
    case s of
        [] -> Ok []
        (x, y) :: tail ->
            unify tail
            |> Result.andThen (\tail_ ->
                unifyOne (apply tail_ x) (apply tail_ y)
                |> Result.map (\unified_head -> 
                    unified_head ++ tail_
                )
            )