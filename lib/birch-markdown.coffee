{Disposable, CompositeDisposable} = require 'atom'
BirchToMarkdown = require './birch-to-markdown'

module.exports = BirchMarkdown =
  activate: (state) ->

  consumeBirchOutlineEditorService: (birchOutlineEditorService) ->
    @birchOutlineEditorService = birchOutlineEditorService
    @birchSubscriptions = new CompositeDisposable
    @birchSubscriptions.add atom.commands.add 'birch-outline-editor',
      'birch-markdown:make-paragraph': => @setItemType()
      'birch-markdown:make-heading': => @setItemType('heading')
      'birch-markdown:make-ordered-list': => @setItemType('orderedlist')
      'birch-markdown:make-unordered-list': => @setItemType('unorderedlist')
      'birch-markdown:make-code-block': => @setItemType('codeblock')
      'birch-markdown:make-block-quote': => @setItemType('blockquote')
      'birch-markdown:copy-as-markdown': => @copyAsMarkdown()

    new Disposable =>
      @birchOutlineEditorService = null
      @birchSubscriptions.dispose()
      @birchSubscriptions = null

  deactivate: ->
    @birchSubscriptions?.dispose()

  setItemType: (type) ->
    editor = @birchOutlineEditorService?.getActiveOutlineEditor()
    items = editor?.selection.items
    if editor and items.length > 0
      outline = editor.outline
      outline.beginUpdates()
      for each in items
        each.setAttribute 'data-type', type
      outline.endUpdates()

  copyAsMarkdown: () ->
    outline = @birchOutlineEditorService?.getActiveOutlineEditor()?.outline
    if outline
      debugger
      atom.clipboard.write BirchToMarkdown.outlineToMarkdown outline
