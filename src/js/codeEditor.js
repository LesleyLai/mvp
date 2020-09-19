import ace from 'brace/index.js';
import 'brace/mode/text.js';
import 'brace/theme/dawn.js';

class CodeEditor extends HTMLElement {
  constructor() {
    super();

    this.div = document.createElement("div");
    this.div.classList.add("code-editor");
    this.editor = ace.edit(this.div);
    this.editor.getSession().setMode('ace/mode/text');
    this.editor.setTheme('ace/theme/dawn');
    this.editor.setFontSize("14px");
  }
  connectedCallback() {
    this.appendChild(this.div);


    const codeEditorNode = this;
    this.editor.on("change", (_) => {
      const event = new CustomEvent("source-change", {
        detail: { source: this.editor.getValue() }
      });

      codeEditorNode.dispatchEvent(event);
    });
  }

  attributeChangedCallback() {
    const editor = this.editor;
    const source = this.getAttribute("source");
    const document = editor.getSession().getDocument();
    if (document.getValue() != source) {
      document.setValue(source);
    }
  }
  static get observedAttributes() { return ["source"]; }
};

export default CodeEditor;