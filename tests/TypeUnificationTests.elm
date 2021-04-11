module TypeUnificationTests exposing (..)

import Expect
import MVP.Types exposing (..)
import MVP.Unify exposing (unify)
import Test exposing (..)


unifyTests : Test
unifyTests =
    let
        testEq ( description, actual, expect ) =
            test description <|
                \() ->
                    Expect.equal actual (Ok expect)

        testErr err expr =
            test err <|
                \() ->
                    Expect.equal expr (Err err)
    in
    describe "Test for unifyOne of types"
        [ testEq
            ( "Unify type variables"
            , unify [ ( TVar "x", TVar "y" ) ]
            , [ ( "x", TVar "y" ) ]
            )
        , testEq
            ( "Unify unconstraint arrow"
            , unify [ ( TArr (TVar "x") (TVar "y"), TArr (TVar "z") (TVar "w") ) ]
            , [ ( "x", TVar "z" ), ( "y", TVar "w" ) ]
            )
        , testEq
            ( "Unify reverse arrow"
            , unify [ ( TArr (TVar "x") (TVar "y"), TArr (TVar "y") (TVar "x") ) ]
            , [ ( "y", TVar "x" ) ]
            )
        , testErr "Recursive unification"
            (unify [ ( TVar "x", TArr (TVar "x") (TVar "y") ) ])
        ]
