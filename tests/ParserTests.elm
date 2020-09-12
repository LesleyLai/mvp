module ParserTests exposing (..)

import Expect
import MVP.AST.Canonical as AST
import MVP.Parse exposing (parse)
import Test exposing (..)

expression : Test
expression =
    let
        runTest ( description, input, output ) =
            test description <|
                \() ->
                    input
                        |> parse
                        |> Result.map AST.toString
                        |> Expect.equal (Ok output)
    in
    describe "Test for the parser"
        (List.map runTest
            [ ( "True", "True", "True" )
            , ( "False", "False", "False" )
            , ( "Integer", "42", "42" )
            , ( "Unit", "()", "unit" )
            , ( "Identifier", "x", "x" )
            , ( "Parentheses", "(42)", "42" )
            , ( "Parentheses with space", "( 42 )", "42" )
            , ( "Lambda with single parameter"
              , "\\x -> x"
              , "(lambda (x) x)"
              )
            , ( "Lambda with multiple parameter"
              , "\\x -> \\y -> x + y"
              , "(lambda (x) (lambda (y) ((+ x) y)))"
              )
            , ( "Application", "f x", "(f x)" )
            , ( "Application with paranthesis", "f(x)", "(f x)" )
            , ( "Application on complex expression"
              , "(\\x -> x)(3)"
              , "((lambda (x) x) 3)"
              )
            , ( "Application with multiple args", "f x y", "((f x) y)" )
            , ( "Arithmatic expressions"
              , "1 + 2 * 3 / 4 - x"
              , "((- ((+ 1) ((/ ((* 2) 3)) 4))) x)"
              )
            , ( "Arithmatic expressions with paranthesis"
              , "(1 + x) / 3"
              , "((/ ((+ 1) x)) 3)"
              )
            ]
        )
