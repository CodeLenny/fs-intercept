path = require "path"
tmp = require "tmp"

statBackup = require("fs").stat

InterceptorRule = require "../../InterceptRule"

###
File read interceptor that compiles the matching Blade file when HTML files are requested.
###
class BladeInterceptor extends InterceptorRule

  intercept: (method, [file]) -> path.extname(file) is ".html"

  stat: (file, cb) ->
    tmp.file {discardDescriptor: yes}, (err, path, fd, cleanup) =>
      _err = (err) ->
        cleanup()
        cb err
      if err then return _err err
      @readFile file, "utf8", (err, html) ->
        if err then return _err err
        require("fs").writeFile path, html, (err) ->
          if err then return _err err
          statBackup path, (err, stats) ->
            if err then return _err err
            cleanup()
            cb null, stats
    #require("fs").stat (file.replace ".html", ".blade"), cb

  readFile: (file, options, cb) ->
    require("fs").readFile (file.replace ".html", ".blade"), "utf8", (err, blade) ->
      return cb err if err
      require("blade").compile blade, {}, (err, tmpl) ->
        return cb err if err
        tmpl {}, (err, html) ->
          return cb err if err
          cb null, html

module.exports = BladeInterceptor
