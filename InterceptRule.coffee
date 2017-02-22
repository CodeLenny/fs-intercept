###
Describes a pattern of files to intercept.
###
class InterceptRule

  ###
  @property {Boolean} If `false`, this rule is only checked when a file fails to be read.  If `true`, the intercept is
  checked even after a file is successfully found.
  ###
  interceptSuccess: no

  ###
  Determine if the given file should be intercepted by this rule.
  @param {String} method the `fs` method being called, e.g. `"readFile"`
  @param {Array} params the parameters provided to the `fs` call.
  @return {Boolean} if `true`, the file read will be intercepted by this rule.
  ###
  intercept: (method, params) -> no

  ###
  A replacement `fs.readFile` to run on intercepted files.
  @param {String, Buffer, Integer} file the file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @param {Function} callback `(err, data)`
  ###
  readFile: (file, options, callback) -> callback new TypeError "InterceptRule hasn't defined a 'readFile' method."

  ###
  A replacement `fs.readFileSync` to run on intercepted files.
  By default, wraps `this.readFile` in a `"deasync"` call.  Re-implement with proper syncronous methods to improve
  preformance.
  @param {String, Buffer, Integer} file the file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  ###
  readFileSync: (file, options) ->
    deasync = require("deasync")
    readFile = deasync @readFile
    readFile file, options

  ###
  A replacement `fs.stat` to return when files are intercepted.
  @param {String, Buffer} path
  @param {Function} callback `(err, stats)`
  ###
  stat: (path, callback) -> callback new TypeError "InterceptRule hasn't defined a 'stats' method."

  ###
  A replacement `fs.lstat` to return when files are intercepted.
  By default, calls `this.stat`.
  @param {String, Buffer} path
  @param {Function} callback `(err, stats)`
  ###
  lstat: (args...) -> this.stat args...

  ###
  If {InterceptRule#interceptSuccess} is `true`, `readFileAlways` is called after a successful read.
  @param {String, Buffer, Integer} file the original file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @param {String, Buffer} data the contents of the file
  @param {Function} callback `(err, data)`
  ###
  readFileAlways: (file, options, data, callback) -> cb null, data

  ###
  A replacement `fs.createReadStream` to return when files are intercepted.
  By default, wraps `this.readFile` in a Stream.  Can be overridden to use proper Streams for better preformance.
  @param {String, Buffer} path
  @param {Object} options
  @option options {String} flags
  @option options {String} encoding
  @option options {Integer} fd
  @option options {Integer} mode
  @option options {Boolean} autoClose
  @option options {Integer} start
  @option options {Integer} end
  @return {ReadStream}
  ###
  createReadStream: (path, options) ->
    stream = require "stream"
    s = new stream.Readable()
    s._read = ->
    @readFile path, options, (err, data) ->
      return s.emit "error", err if err
      s.push data
      s.push null
    return s

  ###
  If {InterceptRule#interceptSuccess} is `true`, `createReadStreamAlways` is called after a successful stream creation.
  By default, wraps `this.readFileAlways` in a Stream.  Can be overridden to use proper Streams for better performance.

  If errors occur while calling `this.readFileAlways`, the input is passed along without modifications.
  @param {String, Buffer} path
  @param {Object} options
  @option options {String} flags
  @option options {String} encoding
  @option options {Integer} fd
  @option options {Integer} mode
  @option options {Boolean} autoClose
  @option options {Integer} start
  @option options {Integer} end
  @return {TransformStream}
  ###
  createReadStreamAlways: (path, options) ->
    Async2TransformStream = require "./stream-utils/Async2TransformStream"
    new Async2TransformStream (file, cb) => @readFileAlways path, options, file, cb

module.exports = InterceptRule
