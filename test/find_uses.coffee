###
Finds uses of `fs` in `node_modules`.
###
doSearch = ->
  path = require "path"
  grep = require "simple-grep"

  ignoredModules = ["fs.extra", "rimraf", "superagent", "mocha", "coffee-script", "chai", "chai-http"]

  isValidFile = (result) ->
    _path = result.file
    return no if path.extname(_path) in [".md", ".html", ".json", ".markdown"]
    return no if path.basename(_path) in [".npmignore", "LICENSE", "C"]
    return no if _path.indexOf("/test/") > -1
    for mod in ignoredModules
      return no if _path.indexOf("node_modules/#{mod}/") > -1
    yes

  grep "fs.", path.resolve("#{__dirname}/../node_modules"), (results) ->
    results = results.filter isValidFile
    console.log results.length
    console.log file for {file} in results

if require.main is module
  doSearch()
