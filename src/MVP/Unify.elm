module MVP.Unify exposing (Substitution, unify)

import MVP.Data.Identifier exposing (Identifier)
import MVP.Types exposing (Type(..))



-- Invariant for substitutions: no id on a lhs occurs in any term earlier


type alias Substitution =
    List ( Identifier, Type )



-- Checks if a variable occurs in a type t


occurs : Identifier -> Type -> Bool
occurs x t =
    case t of
        TVar y ->
            x == y

        TArr u v ->
            occurs x u || occurs x v

        _ ->
            False



-- Substitute type s for all occurrences of var x in type t


subst : Type -> Identifier -> Type -> Type
subst s x t =
    case t of
        TVar y ->
            if x == y then
                s

            else
                t

        TArr tParam tRet ->
            TArr (subst s x tParam) (subst s x tRet)

        _ ->
            t



-- apply a substitution to t right to left


apply : Substitution -> Type -> Type
apply s t =
    List.foldr (\( x, e ) -> subst e x) t s



-- Tries to unify two types


unifyOne : Type -> Type -> Result String Substitution
unifyOne s t =
    case ( s, t ) of
        ( TVar x, TVar y ) ->
            Ok <|
                if x == y then
                    []

                else
                    [ ( x, t ) ]

        ( TVar x, _ ) ->
            if occurs x t then
                Err "Recursive unification"

            else
                Ok [ ( x, t ) ]

        ( _, TVar x ) ->
            unifyOne t s

        ( TInt, TInt ) ->
            Ok []

        ( TBool, TBool ) ->
            Ok []

        ( TUnit, TUnit ) ->
            Ok []

        ( TArr tParam1 tRet1, TArr tParam2 tRet2 ) ->
            unify [ ( tParam1, tParam2 ), ( tRet1, tRet2 ) ]

        _ ->
            Err "Cannot unify distinct types"



-- Tries to unify a list of pairs


unify : List ( Type, Type ) -> Result String Substitution
unify s =
    case s of
        [] ->
            Ok []

        ( x, y ) :: tail ->
            unify tail
                |> Result.andThen
                    (\tail_ ->
                        unifyOne (apply tail_ x) (apply tail_ y)
                            |> Result.map
                                (\unified_head ->
                                    unified_head ++ tail_
                                )
                    )
