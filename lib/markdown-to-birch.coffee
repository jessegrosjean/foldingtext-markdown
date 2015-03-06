commonmark = require 'commonmark'

module.exports = markdownToBirch = (markdown, birchService) ->
  reader = new commonmark.Parser
  ast = reader.parse markdown
  astToBirch ast, birchService

astToBirch = (block, birchService) ->
  outline = new birchService.Outline
  containerItemStack = [outline.root]
  formattingElementsStack = [{}]
  listContextStack = []
  walker = block.walker()
  currentItem

  containerItem = ->
    containerItemStack[containerItemStack.length - 1]

  popContainerItemsWhile = (callback) ->
    while callback(containerItem())
      containerItemStack.pop()

  formattingElements = ->
    formattingElementsStack[formattingElementsStack.length - 1]

  updateFormattingElements = (tagName, attributes, pushing) ->
    if pushing
      newFormattingElements = JSON.parse JSON.stringify formattingElements()
      newFormattingElements[tagName] = attributes
      formattingElementsStack.push newFormattingElements
    else
      formattingElementsStack.pop()

  listContext = ->
    listContextStack[listContextStack.length - 1]

  isEmptyContainer = ->
    item = containerItem()
    type = item.attribute 'data-type'
    (type is 'BlockQuote' or
    type is 'Bullet' or
    type is 'Ordered') and
    item.bodyText.length is 0

  while event = walker.next()
    entering = event.entering
    node = event.node

    switch node.type
      when 'Text'
        currentItem.appendBodyText node.literal, formattingElements()

      when 'Softbreak'
        currentItem.appendBodyText ' ', formattingElements()

      when 'Hardbreak'
        currentItem.insertLineBreakInBodyText currentItem.bodyText.length

      when 'Emph'
        updateFormattingElements 'I', {}, entering

      when 'Strong'
        updateFormattingElements 'B', {}, entering

      when 'Html'
        break

      when 'Link'
        updateFormattingElements 'A', href: node.destination, entering

      when 'Image'
        break

      when 'Code'
        currentItem.appendBodyText node.literal, 'CODE' : {}

      when 'Document'
        break

      when 'Paragraph'
        if entering
          unless isEmptyContainer()
            currentItem = outline.createItem()
            containerItem().appendChild currentItem

      when 'BlockQuote'
        if entering
          currentItem = outline.createItem()
          currentItem.setAttribute 'data-type', 'BlockQuote'
          containerItem().appendChild currentItem
          containerItemStack.push currentItem
        else
          containerItemStack.pop()

      when 'Item'
        if entering
          currentItem = outline.createItem()
          currentItem.setAttribute 'data-type', listContext().listType
          containerItem().appendChild currentItem
          containerItemStack.push currentItem
        else
          containerItemStack.pop()

      when 'List'
        if entering
          listContextStack.push
            listType: node.listType
        else
          listContextStack.pop()

      when 'Header'
        if entering
          currentItem = outline.createItem()
          currentItem.setAttribute 'data-type', 'Header'
          currentItem.headerLevel = node.level
          popContainerItemsWhile (eachItem) ->
            eachItem.attribute('data-type') is 'Header' and
            eachItem.headerLevel >= currentItem.headerLevel
          containerItem().appendChild currentItem
          containerItemStack.push currentItem

      when 'CodeBlock'
        for eachLine in node.literal.split '\n'
          currentItem = outline.createItem()
          currentItem.bodyText = eachLine
          currentItem.setAttribute 'data-type', 'CodeBlock'
          containerItem().appendChild currentItem

      when 'HtmlBlock'
        for eachLine in node.literal.split '\n'
          currentItem = outline.createItem()
          currentItem.bodyText = eachLine
          containerItem().appendChild currentItem

      when 'HorizontalRule'
        currentItem = outline.createItem()
        currentItem.bodyText = '* * *'
        containerItem().appendChild currentItem

      else
        throw new Error 'Unknown node type ' + node.type

  outline