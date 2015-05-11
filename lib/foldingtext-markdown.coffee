{Disposable, CompositeDisposable} = require 'atom'
foldingTextToMarkdown = null
markdownToFoldingText = null

module.exports = FoldingMarkdown =
  config:
    indentMarkdownUsingSpaces:
      title: 'Indent Markdown using spaces'
      description: 'When converting an outline to Markdown spaces or tabs will be used for indentation.'
      type: 'boolean'
      default: true

  activate: (state) ->

  consumeFoldingTextService: (foldingTextService) ->
    @foldingTextService = foldingTextService
    @foldingTextSubscriptions = new CompositeDisposable
    @foldingTextSubscriptions.add atom.commands.add 'ft-outline-editor',
      'foldingtext-markdown:make-paragraph': => @setItemType('Paragraph')
      'foldingtext-markdown:make-header': => @setItemType 'Header'
      'foldingtext-markdown:make-ordered-list': => @setItemType 'Ordered'
      'foldingtext-markdown:make-bullet-list': => @setItemType 'Bullet'
      'foldingtext-markdown:make-code-block': => @setItemType 'CodeBlock'
      'foldingtext-markdown:make-block-quote': => @setItemType 'BlockQuote'
      'foldingtext-markdown:copy-markdown': => @copyMarkdown()
      'foldingtext-markdown:paste-markdown': => @pasteMarkdown()

    new Disposable =>
      @foldingTextService = null
      @foldingTextSubscriptions.dispose()
      @foldingTextSubscriptions = null

  deactivate: ->
    @foldingTextSubscriptions?.dispose()

  setItemType: (type) ->
    editor = @foldingTextService?.getActiveOutlineEditor()
    items = editor?.selection.items
    if editor and items?.length > 0
      outline = editor.outline
      outline.beginUpdates()
      for each in items
        each.setAttribute 'data-type', type
      outline.endUpdates()

  copyMarkdown: ->
    outline = @foldingTextService?.getActiveOutlineEditor()?.outline
    if outline
      foldingTextToMarkdown ?= require './foldingtext-to-markdown'
      markdown = foldingTextToMarkdown outline
      atom.clipboard.write markdown

  pasteMarkdown: ->
    outline = @foldingTextService?.getActiveOutlineEditor()?.outline
    if outline
      markdown = atom.clipboard.read()
      if markdown
        markdownToFoldingText ?= require './markdown-to-foldingtext'
        markdownOutline = markdownToFoldingText markdown, @foldingTextService
        for each in markdownOutline.root.children
          outline.root.appendChild outline.importItem each