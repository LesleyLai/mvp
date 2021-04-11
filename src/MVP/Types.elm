module MVP.Types exposing (Type(..))

import MVP.Data.Identifier exposing (Identifier)


type alias Kind =
    Int


type Type
    = TVar Identifier
    | TInt
    | TBool
    | TUnit
    | TArr Type Type
