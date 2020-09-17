import ace from 'brace/index.js';
import 'brace/mode/text.js';
import 'brace/theme/dawn.js';

import firstmd from '../contents/first.md';

class CodeEditor extends HTMLElement {
    constructor() { super(); }
    connectedCallback() {
      const div = document.createElement("div");
      div.classList.add("code-editor");
      this.appendChild(div);
      const editor = ace.edit(div);
      editor.getSession().setMode('ace/mode/text');
      editor.setTheme('ace/theme/dawn');
      editor.setFontSize("14px");

      const codeEditorNode = this;
      editor.on("change", (_) => {
        const event = new CustomEvent("source-change", {
          detail: { source: editor.getValue() }
        });

        codeEditorNode.dispatchEvent(event);
      });

      const wrapper= document.createElement('div');
      wrapper.innerHTML= firstmd;
      this.appendChild(wrapper);
    }
};

export default CodeEditor;