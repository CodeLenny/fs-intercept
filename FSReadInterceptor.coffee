stream = require "stream"
ReadableStreamBackup = require "./stream-utils/ReadableStreamBackup"

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
    @backup.createReadStream ?= require("fs").createReadStream

  ###
  Add a new {InterceptRule}.
  @param {InterceptRule} rule the rule to add
  @return {FSReadInterceptor} for chaining
  ###
  use: (rule) ->
    @intercepts.push rule
    @

  ###
  Starts intercepting file reads.
  @return {FSReadInterceptor} for chaining
  ###
  intercept: ->
    require("fs").readFile = @interceptedReadFile
    require("fs").stat = @interceptedStat
    require("fs").createReadStream = @interceptedCreateReadStream
    @

  ###
  Stops intercepting file reads.
  @return {FSReadInterceptor} for chaining.
  ###
  bypass: ->
    require("fs").readFile = @backup.readFile
    require("fs").stat = @backup.stat
    require("fs").createReadStream = @backup.createReadStream
    @

  ###
  Abstract method to intercept `fs` calls.
  @param {String} method the method to call
  @param {Array<Any>} params parameters to pass to the original function as well as intercepted methods.
  @param {Object} opts options to control the intercept.  Options to be passed to `fs` calls should be included in
    `params`.
  @option opts {Boolean} always if `true`, the `Always` version of methods will be called - for instance,
    `readFileAlways` would be called after `readFile`.
  @param {Function} cb called with the results of the intercepted calls.
  @private
  ###
  interceptedCall: (method, params, opts, cb) ->
    onFailure = @intercepts.filter (intercept) -> intercept.intercept method, params
    always = if opts.always then onFailure.filter (intercept) -> intercept.interceptSuccess else []
    ###
    If the original `fs` call fails, recursively try intercepts until one succeeds.
    ###
    failureBackup = (err, cb) ->
      return cb err if onFailure.length < 1
      intercept = onFailure.pop()
      intercept[method] params..., (_err, res...) ->
        return failureBackup err, cb if _err
        cb null, res...
    ###
    If `opts.always`, allow each intercept to transform the output.
    @param {Array<Any>} data the values included in the callback.
    ###
    runAlways = (data, cb) ->
      return cb null, data... if always.length < 1
      intercept = always.pop()
      intercept["#{method}Always"] params..., data..., (err, _data...) ->
        data = _data unless err
        runAlways data, cb
    @backup[method] params..., (err, data...) ->
      unless err
        return runAlways data, cb
      failureBackup err, (err, data...) ->
        return cb err if err
        runAlways data, cb

  ###
  Abstract method to intercept `fs` sync calls.
  @param {String} method the method to call
  @param {Array<Any>} params parameters to pass to the original function as well as intercepted methods.
  @param {Object} opts options to control the intercept.  Options to be passed to `fs` calls should be included in
    `params`.
  @option opts {Boolean} always if `true`, the `Always` version of methods will be called - for instance,
    `readFileAlways` would be called after `readFile`.
  @return {Any} the output of the function.
  @todo see if switching to `for` loop would shorten code/improve performance
  @private
  ###
  interceptedCallSync: (method, params, opts) ->
    onFailure = @intercepts.filter (intercept) -> intercept.intercept method, params
    always = if opts.always then onFailure.filter (intercept) -> intercept.interceptSuccess else []
    failureBackup = (err) ->
      throw err if onFailure.length < 1
      intercept = onFailure.pop()
      try
        return intercept[method] params...
      catch error
        failureBackup err
    runAlways = (out) ->
      return out if always.length < 1
      intercept = always.pop()
      try
        return runAlways intercept["#{method}Always"] params..., out
      catch error
        runAlways params..., out
    output = null
    try
      output = @backup[method] params...
    catch error
      output = failureBackup error
    if opts.always then output = runAlways output
    return output

  ###
  Abstract method to intercept `fs` calls returning Streams.
  @param {String} method the method to call
  @param {Array<Any>} params parameters to pass to the original function as well as intercepted methods.
  @param {Object} opts options to control the intercept.  Options to be passed to `fs` calls should be included in
    `params`.
  @option opts {Boolean} always if `true`, the `Always` version of methods will be called - for instance,
    `readFileAlways` would be called after `readFile`.
  @return {ReadStream}
  @todo consider improving preformance by actually streaming output (but figure out how that will effect error catching)
  @private
  ###
  interceptedStreamCall: (method, params, opts) ->
    onFailure = @intercepts.filter (intercept) -> intercept.intercept method, params
    always = onFailure.filter (intercept) -> intercept.interceptSuccess

    data = @backup[method] params...
    for intercept in onFailure
      do (intercept) ->
        data = new ReadableStreamBackup data, -> intercept[method] params...

    if opts.always
      for intercept in always
        data = data.pipe intercept["#{method}Always"] params...

    return data

  ###
  Intercepts a `readFile`.
  @param {Array<Any>} opts the options passed to `fs.readFile`.
  @option {Function} cb
  ###
  interceptedReadFile: (opts..., cb) =>
    @interceptedCall "readFile", opts, {always: yes}, cb

  ###
  Intercepts a `stat`.
  @param {Array<Any>} opts the options passed to `fs.stat`.
  @param {Function} cb given `(err, stats)`.
  ###
  interceptedStat: (opts..., cb) =>
    @interceptedCall "stat", opts, {}, cb

  ###
  Intercepts a `createReadStream`.
  @param {Array<Any>} opts the options passed to `fs.createReadStream`.
  @param {Function} cb given `(err, stream)`.
  ###
  interceptedCreateReadStream: (opts...) =>
    @interceptedStreamCall "createReadStream", opts, {always: yes}

module.exports = FSReadInterceptor
