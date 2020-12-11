class MarkdownView extends HTMLElement {
  constructor() {
    super();
    this.div = document.createElement("div");
    this.div.classList.add("markdown-view");
  }
  connectedCallback() {
    this.appendChild(this.div);
  }
  static get observedAttributes() { return ["filename"]; }
  attributeChangedCallback() {
    const filename = this.getAttribute("filename");
    if (filename == "") {
      this.div.innerHTML = "";
      return;
    }
    import(`../../contents/semantics/${filename}`)
      .then(md => { this.div.innerHTML = md.default; });
  }
};

export default MarkdownView;