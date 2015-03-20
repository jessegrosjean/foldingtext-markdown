{Disposable, CompositeDisposable} = require 'atom'
birchToMarkdown = null
markdownToBirch = null

module.exports = BirchMarkdown =
  config:
    indentMarkdownUsingSpaces:
      title: 'Indent Markdown using spaces'
      description: 'When converting an outline to Markdown spaces or tabs will be used for indentation.'
      type: 'boolean'
      default: true

  activate: (state) ->

  consumeBirchOutlineEditorService: (birchOutlineEditorService) ->
    @birchOutlineEditorService = birchOutlineEditorService
    @birchSubscriptions = new CompositeDisposable
    @birchSubscriptions.add atom.commands.add 'birch-outline-editor',
      'birch-markdown:make-paragraph': => @setItemType('Paragraph')
      'birch-markdown:make-header': => @setItemType 'Header'
      'birch-markdown:make-ordered-list': => @setItemType 'Ordered'
      'birch-markdown:make-bullet-list': => @setItemType 'Bullet'
      'birch-markdown:make-code-block': => @setItemType 'CodeBlock'
      'birch-markdown:make-block-quote': => @setItemType 'BlockQuote'
      'birch-markdown:copy-markdown': => @copyMarkdown()
      'birch-markdown:paste-markdown': => @pasteMarkdown()

    new Disposable =>
      @birchOutlineEditorService = null
      @birchSubscriptions.dispose()
      @birchSubscriptions = null

  deactivate: ->
    @birchSubscriptions?.dispose()

  setItemType: (type) ->
    editor = @birchOutlineEditorService?.getActiveOutlineEditor()
    items = editor?.selection.items
    if editor and items?.length > 0
      outline = editor.outline
      outline.beginUpdates()
      for each in items
        each.setAttribute 'data-type', type
      outline.endUpdates()

  copyMarkdown: () ->
    outline = @birchOutlineEditorService?.getActiveOutlineEditor()?.outline
    if outline
      birchToMarkdown ?= require './birch-to-markdown'
      markdown = birchToMarkdown outline
      atom.clipboard.write markdown

  pasteMarkdown: () ->
    outline = @birchOutlineEditorService?.getActiveOutlineEditor()?.outline
    if outline
      markdown = atom.clipboard.read()
      if markdown
        markdownToBirch ?= require './markdown-to-birch'
        markdownOutline = markdownToBirch markdown, @birchOutlineEditorService
        for each in markdownOutline.root.children
          outline.root.appendChild outline.importItem each