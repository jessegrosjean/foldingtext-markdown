FoldingMarkdown = require '../lib/foldingtext-markdown'
markdownToFoldingText = require '../lib/markdown-to-foldingtext'
path = require 'path'
fs = require 'fs'

describe "FoldingMarkdown", ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('foldingtext-for-atom')
    waitsForPromise ->
      atom.packages.activatePackage('foldingtext-markdown')

  it "should load FoldingText service", ->
    expect(FoldingMarkdown.foldingTextService).toBeDefined()

  it "should convert Markdown to FoldingText", ->
    fixtures = __dirname + '/fixtures/'
    markdown = fs.readFileSync(fixtures + 'markdown.md', encoding: 'utf8')
    ftExpected = removeIDs fs.readFileSync(fixtures + 'ftexpected.ftml', encoding: 'utf8')
    outline = markdownToFoldingText(markdown, FoldingMarkdown.foldingTextService)
    ftActual = outline.getText()
    fs.writeFile(fixtures + 'ftactual.ftml', ftActual)
    expect(removeIDs ftActual).toEqual ftExpected

removeIDs = (text) ->
  text.replace(/\sid="[^"]+"/g, '')