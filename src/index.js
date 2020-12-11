import "./main.css";
import "katex/dist/katex.css";
import { Elm } from "./Main.elm";

import CodeEditor from "./js/codeEditor";
import MarkdownView from "./MVP/UI/MarkdownView";

customElements.define("code-editor", CodeEditor);
customElements.define("markdown-view", MarkdownView);

Elm.Main.init({
  node: document.getElementById("root")
});