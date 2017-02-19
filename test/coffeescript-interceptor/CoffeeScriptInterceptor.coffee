path = require "path"

InterceptorRule = require "../../InterceptRule"

###
File read interceptor that compiles the matching CoffeeScript file when JavaScript files are requested.
###
class CoffeeScriptInterceptor extends InterceptorRule

  intercept: (file) -> path.extname(file) is ".js"

  stat: (file, cb) ->
    require("fs").stat (file.replace ".js", ".coffee"), cb

  readFile: (file, options, cb) ->
    require("fs").readFile (file.replace ".js", ".coffee"), options, (err, data) ->
      return cb err if err
      cb null, require("coffee-script").compile data

module.exports = CoffeeScriptInterceptor
