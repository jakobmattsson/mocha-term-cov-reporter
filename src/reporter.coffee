_ = require 'underscore'
colors = require 'colors'
mocha = require 'mocha'



pad = (width, str) ->
  padding = width - str.toString().length
  if padding > 0
    [1 .. padding].map( -> ' ').join('') + str.toString()
  else
    str



readReport = (data, surround, callback) ->

  data.files.map (file) ->

    lineCount = Object.keys(file.source).length
    padLineLength = _.bind(pad, null, lineCount.toString().length)

    makeResult = (groups) ->
      filename: file.filename
      sloc: file.sloc
      coverage: parseInt(file.coverage, 10)
      groups: groups

    uncoveredLines = [1 .. lineCount].filter (line) -> file.source[line].coverage == 0

    if uncoveredLines.length == 0
      return makeResult([])

    displayLines = _.unique _.flatten uncoveredLines.map (line) -> [(line - surround) .. (line + surround)]
    actualLines = displayLines.filter (line) -> 1 <= line && line <= lineCount
    sortedLines = _.sortBy(actualLines, _.identity)

    groupedLines = sortedLines.slice(1).reduce (acc, line) ->
      group = _.last(acc)
      value = _.last(group)

      if value + 1 == line
        group.push(line)
      else
        acc.push([line])

      acc
    , [[sortedLines[0]]]

    makeResult groupedLines.map (group) ->
      group.map (line) ->
        source: "#{padLineLength(line)} #{file.source[line].source}"
        covered: uncoveredLines.indexOf(line) == -1



printSummary = (stream, dd) ->
  dd.forEach (file) ->
    title = "#{file.filename}: #{file.sloc} lines, #{file.coverage}% coverage"
    color = if file.groups.length == 0 then 'green' else 'red'
    stream.write("#{title[color]}\n")



printFileReport = (stream, file) ->
  title = "#{file.filename}: #{file.sloc} lines, #{file.coverage}% coverage"

  if file.groups.length == 0
    stream.write(title.bold.green)
    stream.write('\n')
  else
    stream.write(title.bold)
    stream.write('\n')
    stream.write([1 .. 80].map((x) -> '=').join('').bold)
    stream.write('\n')

    file.groups.forEach (group) ->
      group.forEach (line) ->
        stream.write(if line.covered then line.source else line.source.red.inverse)
        stream.write('\n')
      stream.write('\n\n\n')



printFullReport = (stream, data) ->
  printSummary(stream, data)
  if data.some((file) -> file.groups.length > 0)
    stream.write('\n\n\n')
    data.filter((file) -> file.groups.length > 0).forEach (file) ->
      printFileReport(stream, file)
    printSummary(stream, data)



module.exports = (runner) ->
  info = {}
  mocha.reporters.JSONCov.call(info, runner, false)
  runner.on 'end', ->
    outdata = readReport(info.cov, 5)
    printFullReport(process.stdout, outdata)
