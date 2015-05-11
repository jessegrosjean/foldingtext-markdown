# foldingtext-markdown package

*This is a work in progress* to author Markdown in the [FoldingText for Atom](https://atom.io/packages/foldingtext-for-atom) outliner.

This package contains commands for setting Markdown `data-type`s on items. [CommonMark](http://commonmark.org/) is used for the transform from Markdown to FoldingText and CommonMark AST type names are used for `data-type` values. Example types include `Header`, `CodeBlock`, `Ordered`, etc. It also contains styles so those types are visible in the outline editor. And it also includes a "Copy/Paste Markdown" commands that will convert the current outline from/to Markdown text on the clipboard.

## To install

1. Download this package

2. Open this package directory in Terminal.app and then:

	- `apm install`

	- `apm link`