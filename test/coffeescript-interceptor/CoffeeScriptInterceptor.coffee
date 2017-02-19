path = require "path"
tmp = require "tmp"

statBackup = require("fs").stat

InterceptorRule = require "../../InterceptRule"

###
File read interceptor that compiles the matching CoffeeScript file when JavaScript files are requested.
###
class CoffeeScriptInterceptor extends InterceptorRule

  intercept: (method, [file]) -> path.extname(file) is ".js"

  stat: (file, cb) ->
    tmp.file {discardDescriptor: yes}, (err, path, fd, cleanup) =>
      _err = (err) ->
        cleanup()
        cb err
      if err then return _err err
      @readFile file, "utf8", (err, js) ->
        if err then return _err err
        require("fs").writeFile path, js, (err) ->
          if err then return _err err
          statBackup path, (err, stats) ->
            if err then return _err err
            cleanup()
            cb null, stats
    #require("fs").stat (file.replace ".js", ".coffee"), cb

  readFile: (file, options, cb) ->
    require("fs").readFile (file.replace ".js", ".coffee"), "utf8", (err, data) ->
      return cb err if err
      cb null, require("coffee-script").compile data

module.exports = CoffeeScriptInterceptor
