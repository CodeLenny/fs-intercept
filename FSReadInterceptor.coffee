###
Intercepts calls to `fs.readFileAsync`, preforming transformations and other actions.
###
class FSReadInterceptor

  ###
  @property {Array<InterceptRule>} The loaded modules that will be used to intercept file reads.
  ###
  intercepts: null

  ###
  @property {Object} stores a copy of the unmodified `readFile`
  ###
  backup: null

  ###
  @param {Object} opts overrides any local parameters.
  ###
  constructor: (opts = {})->
    Object.assign @, opts
    @intercepts ?= []
    @backup ?= {}
    @backup.readFile ?= require("fs").readFile
    @backup.stat ?= require("fs").stat

  ###
  Add a new {InterceptRule}.
  @param {InterceptRule} rule the rule to add
  @return {FSReadInterceptor} for chaining
  ###
  use: (rule) -> @intercepts.push rule

  ###
  Starts intercepting file reads.
  @return {FSReadInterceptor} for chaining
  ###
  intercept: ->
    require("fs").readFile = @interceptedReadFile
    require("fs").stat = @interceptedStat
    @

  ###
  Stops intercepting file reads.
  @return {FSReadInterceptor} for chaining.
  ###
  bypass: ->
    require("fs").readFile = @backup.readFile
    require("fs").stat = @backup.stat
    @

  ###
  Intercepts a `readFile`.
  @param {String, Buffer, Integer} file the file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @option {Function} cb
  ###
  interceptedReadFile: (file, options, cb) =>
    [cb, options] = [options] unless cb
    onFailure = @intercepts.filter (intercept) -> intercept.intercept file, options
    always = onFailure.filter (intercept) -> intercept.interceptSuccess
    readFileBackup = (err, cb) ->
      return cb err if onFailure.length < 1
      intercept = onFailure.pop()
      intercept.readFile file, options, (_err, data) ->
        return readFileBackup err, cb if _err
        cb null, data
    runAlways = (data, cb) ->
      return cb null, data if always.length < 1
      intercept = always.pop()
      intercept.readFileAlways data, file, options, (err, data) ->
        runAlways data, cb
    @backup.readFile file, options, (err, data) ->
      if err
        return readFileBackup err, (err, data) ->
          return cb err if err
          runAlways data, cb
      runAlways data, cb

  ###
  Intercepts a `stat`.
  @param {String, Buffer} path the file path requested
  @param {Function} cb given `(err, stats)`.
  ###
  interceptedStat: (path, cb) =>
    onFailure = @intercepts.filter (intercept) -> intercept.intercept path, {}
    statBackup = (err, cb) ->
      return cb err if onFailure.length < 1
      intercept = onFailure.pop()
      intercept.stat path, (_err, stats) ->
        return statBackup err, cb if _err
        cb null, stats
    @backup.stat path, (err, data) ->
      if err
        return statBackup err, cb
      cb err, data

module.exports = FSReadInterceptor
