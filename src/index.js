import './main.css';
import { Elm } from './Main.elm';

import CodeEditor from './js/codeEditor';

customElements.define('code-editor', CodeEditor);

Elm.Main.init({
  node: document.getElementById('root')
});