module TypeUnificationTests exposing (..)

import Expect
import MVP.Types exposing (Type(..))
import MVP.Unify exposing (unifyOne)
import Test exposing (..)


unifyOneTests : Test
unifyOneTests =
    let
        testEq ( description, actual, expect ) =
            test description <|
                \() ->
                    Expect.equal actual (Ok expect)
    in
    describe "Test for unifyOne of types"
        [ testEq
            ( "Unify type variables"
            , unifyOne (TVar "x") (TVar "y")
            , [ ( "x", TVar "y" ) ]
            )
        , testEq
            ( "Unify unconstraint arrow"
            , unifyOne (TArrow (TVar "x") (TVar "y")) (TArrow (TVar "z") (TVar "w"))
            , [("x",TVar "z"),("y",TVar "w")]
            )
        , testEq
            ( "Unify reverse arrow"
            , unifyOne (TArrow (TVar "x") (TVar "y")) (TArrow (TVar "y") (TVar "x"))
            , [("y",TVar "x")]
            )
        ]
