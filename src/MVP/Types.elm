module MVP.Types exposing (Type(..))

import MVP.Data.Identifier exposing (Identifier)

type Type
    = TVar Identifier
    | TArrow Type Type