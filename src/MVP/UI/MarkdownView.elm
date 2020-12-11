module MVP.UI.MarkdownView exposing (markdownView)

import Html exposing (Html, node)
import Html.Attributes exposing (attribute)


markdownView : String -> Html msg
markdownView filename =
    node "markdown-view"
        [ attribute "filename" filename ]
        []
