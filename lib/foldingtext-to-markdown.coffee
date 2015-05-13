commonmark = require 'commonmark'
toMarkdown = require('to-markdown')

### Rewrite all of this to first generate CommonMark AST and then generate
HTML or Markdown from that.

module.exports = foldingTextToMarkdown = (items, foldingTextService) ->

itemToAST = (item) ->
  type = item.getAttribute('data-type') or 'Paragraph'

  switch type
    when 'Paragraph'
      new commonmark.Node('Paragraph')
    when 'Header'
    when 'CodeBlock'

    when 'BlockQuote'
    when 'Bullet'
    when 'Ordered'

    else
      throw new Error 'Unknown node type ' + node.type

itemBodyContentToAST = (item) ->
###

repeat = (str, n) ->
  res = ''
  while n > 0
    res += str if n & 1
    n >>>= 1
    str += str
  res

indent = (n) ->
  if atom.config.get 'foldingtext-markdown.indentMarkdownUsingSpaces'
    repeat('    ', n)
  else
    repeat('\t', n)

class FTToMarkdown
  @outlineToMarkdown: (outline) ->
    results = []
    context =
      listIndex: 0
      listLevel: 0
      headerLevel: 0
    for each in outline.root.children
      @visiItem each, context, results
    results.join '\n\n'

  @visiItem: (item, context, results) ->
    type = item.getAttribute('data-type') or 'PARAGRAPH'
    type = type.toUpperCase()

    @['willVisit' + type]?(item, context)

    if itemMarkdown = @['visit' + type]?(item, context)
      results.push itemMarkdown
    else
      console.log "Unknown Item Type: #{type}, rendering as PARAGRAPH"
      results.push @visitPARAGRAPH(item, context)

    for each in item.children
      @visiItem each, context, results

    @['didVisit' + type]?(item, context)


  @visitPARAGRAPH: (item, context) ->
    indent(context.listLevel) + toMarkdown item.bodyHTML

  @visitCODEBLOCK: (item, context) ->
    indent(context.listLevel) + '    ' + item.bodyHTML

  @visitBLOCKQUOTE: (item, context) ->
    indent(context.listLevel) + '> ' + toMarkdown item.bodyHTML

  @visitHEADER: (item, context) ->
    context.listIndex = 0
    context.listLevel = 0
    context.headerLevel++
    repeat('#', context.headerLevel) + ' ' + toMarkdown item.bodyHTML

  @didVisitHEADER: (item, context) ->
    context.headerLevel--


  @visitORDERED: (item, context) ->
    context.listIndex++
    context.listLevel++
    indent(context.listLevel - 1) + context.listIndex + '. ' + toMarkdown item.bodyHTML

  @didVisitORDERED: (item, context) ->
    if context.listLevel > 0
      context.listLevel--

  @visitBULLET: (item, context) ->
    context.listLevel++
    indent(context.listLevel - 1) + '- ' + toMarkdown item.bodyHTML

  @didVisitBULLET: (item, context) ->
    if context.listLevel > 0
      context.listLevel--

module.exports = FTToMarkdown.outlineToMarkdown.bind(FTToMarkdown)
###
