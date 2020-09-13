module MVP.Data.Builtins exposing (BinaryOp(..), binaryOpName)
import MVP.Data.Identifier exposing (Identifier)

type BinaryOp
    = Plus
    | Minus
    | Multiplies
    | Divides

binaryOpName : BinaryOp -> Identifier
binaryOpName op =
    case op of
        Plus -> "+"
        Minus -> "-"
        Multiplies -> "✕"
        Divides -> "÷"