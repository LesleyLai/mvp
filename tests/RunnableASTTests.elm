module RunnableASTTests exposing (..)

import Expect
import MVP.AST.Runnable as AST exposing (Expr(..))
import Test exposing (..)

isValueTests : Test
isValueTests =
    let
        runTest ( description, e, isValue ) =
            test description <|
                \() ->
                    e
                        |> AST.isValue
                        |> Expect.equal isValue
    in
    describe "Test for the isValue function of AST.Runnable"
        (List.map runTest
            [ ( "A boolean is a value", Bool True, True )
            , ( "An integer is a value", Int 42, True )
            , ( "Unit is a value", Unit, True )
            , ( "A variable is not a value", Var "x", False )
            , ( "A lambda is a value"
              , Lambda
                    { param = "x"
                    , body = Bool True
                    }
              , True
              )
            , ( "A function application is not a value"
              , App
                    { func = Var "f"
                    , arg = Var "x"
                    }
              , False
              )
            , ("Plus is not a value", Plus (Var "x") (Var "y"), False)
            ]
        )