module MVP.Types exposing (Type(..))

import MVP.Identifier exposing (Identifier)

type Type
    = TVar Identifier
    | TArrow Type Type