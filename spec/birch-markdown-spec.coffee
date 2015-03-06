markdownToBirch = require '../lib/markdown-to-birch'
BirchMarkdown = require '../lib/birch-markdown'
path = require 'path'
fs = require 'fs'

describe "BirchMarkdown", ->
  beforeEach ->
    waitsForPromise ->
      atom.packages.activatePackage('birch-outline-editor')
    waitsForPromise ->
      atom.packages.activatePackage('birch-markdown')

  it "should convert load Birch service", ->
    expect(BirchMarkdown.birchOutlineEditorService).toBeDefined()

  it "should convert Markdown to Birch", ->
    fixtures = __dirname + '/fixtures/'
    markdown = fs.readFileSync(fixtures + 'markdown.md', encoding: 'utf8')
    birchExpected = removeIDs fs.readFileSync(fixtures + 'birchexpected.bml', encoding: 'utf8')
    outline = markdownToBirch(markdown, BirchMarkdown.birchOutlineEditorService)
    birchActual = outline.getText()
    fs.writeFile(fixtures + 'birchactual.bml', birchActual)
    expect(removeIDs birchActual).toEqual birchExpected

removeIDs = (text) ->
  text.replace(/\sid="[^"]+"/g, '')