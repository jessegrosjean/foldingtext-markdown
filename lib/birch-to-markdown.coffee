toMarkdown = require('to-markdown').toMarkdown

repeat = (str, n) ->
  res = ''
  while n > 0
    res += str if n & 1
    n >>>= 1
    str += str
  res

class BirchToMarkdown
  @outlineToMarkdown: (outline) ->
    results = []
    context =
      listIndex: 0
      listLevel: 0
      headingLevel: 0
    for each in outline.root.children
      @visiItem each, context, results
    results.join '\n\n'

  @visiItem: (item, context, results) ->
    type = item.attribute('data-type') or 'PARAGRAPH'
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

  ###
  Paragraphs
  ###

  @visitPARAGRAPH: (item, context) ->
    repeat('    ', context.listLevel) + toMarkdown item.bodyHTML

  @visitCODEBLOCK: (item, context) ->
    repeat('    ', context.listLevel) + '    ' + item.bodyHTML

  @visitBLOCKQUOTE: (item, context) ->
    repeat('    ', context.listLevel) + '>  ' + toMarkdown item.bodyHTML

  ###
  Headings
  ###

  @visitHEADING: (item, context) ->
    context.listIndex = 0
    context.listLevel = 0
    context.headingLevel++
    repeat('#', context.headingLevel) + '  ' + toMarkdown item.bodyHTML

  @didVisitHEADING: (item, context) ->
    context.headingLevel--

  ###
  Lists
  ###

  @visitORDERED: (item, context) ->
    context.listIndex++
    context.listLevel++
    repeat('    ', context.listLevel - 1) + context.listIndex + '.  ' + toMarkdown item.bodyHTML

  @didVisitORDERED: (item, context) ->
    if context.listLevel > 0
      context.listLevel--

  @visitUNORDERED: (item, context) ->
    context.listLevel++
    repeat('    ', context.listLevel - 1) + '- ' + toMarkdown item.bodyHTML

  @didVisitUNORDERED: (item, context) ->
    if context.listLevel > 0
      context.listLevel--

module.exports = BirchToMarkdown
