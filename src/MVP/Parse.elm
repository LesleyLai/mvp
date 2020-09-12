module MVP.Parse exposing (parse)

import MVP.AST.Canonical exposing (Expr(..))
import Parser
    exposing
        ( (|.)
        , (|=)
        , Parser
        , chompWhile
        , end
        , int
        , keyword
        , lazy
        , spaces
        , succeed
        , symbol
        , variable
        )
import Pratt
import Set exposing (Set)


parse : String -> Result (List Parser.DeadEnd) Expr
parse str =
    Parser.run toplevel str


var : Parser Expr
var =
    succeed Var
        |= lowerCaseIdent


reserved : Set String
reserved =
    Set.fromList [ "let", "in", "case", "of" ]


lowerCaseIdent : Parser String
lowerCaseIdent =
    variable
        { start = Char.isLower
        , inner = \c -> Char.isAlphaNum c || c == '_'
        , reserved = reserved
        }


toplevel : Parser Expr
toplevel =
    succeed identity
        |= expr
        |. end


whitespaces : Parser ()
whitespaces =
    succeed ()
        |. chompWhile (\c -> c == ' ')


expr : Parser Expr
expr =
    let
        binaryApp func l r =
            App (App func l) r
    in
    succeed identity
        |. spaces
        |= Pratt.expression
            { oneOf =
                [ Pratt.literal true
                , Pratt.literal false
                , Pratt.literal integer
                , Pratt.literal var
                , Pratt.literal lambda
                , Pratt.literal unit
                , parenExpr
                ]
            , andThenOneOf =
                [ Pratt.infixLeft 99 whitespaces App
                , Pratt.infixLeft 1 (symbol "+") (binaryApp (Var "+"))
                , Pratt.infixLeft 1 (symbol "-") (binaryApp (Var "-"))
                , Pratt.infixLeft 2 (symbol "*") (binaryApp (Var "*"))
                , Pratt.infixLeft 2 (symbol "/") (binaryApp (Var "/"))
                , Pratt.infixRight 4 (symbol "^") (binaryApp (Var "^"))
                ]
            , spaces = Parser.spaces
            }


parenExpr : Pratt.Config Expr -> Parser Expr
parenExpr config =
    succeed identity
        |. symbol "("
        |= Pratt.subExpression 0 config
        |. symbol ")"


integer : Parser Expr
integer =
    succeed Int
        |= int


true : Parser Expr
true =
    succeed (Bool True)
        |. keyword "True"


false : Parser Expr
false =
    succeed (Bool False)
        |. keyword "False"


unit : Parser Expr
unit =
    succeed Unit
        |. symbol "()"


lambda : Parser Expr
lambda =
    succeed Lambda
        |. symbol "\\"
        |. spaces
        |= lowerCaseIdent
        |. spaces
        |. symbol "->"
        |. spaces
        |= lazy (\_ -> expr)
