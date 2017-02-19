stream = require "stream"

###
Creates a TransformStream from an asyncronous function.
###
class Async2TransformStream extends stream.Transform

  ###
  @param {Function} fn an asyncronous function that takes a String and a callback, and calls the callback with
    `(err, [String] output)`.
  ###
  constructor: (@fn, opts) ->
    super opts
    this.contents = ""

  _transform: (chunk, enc, cb) ->
    this.contents += chunk.toString()
    cb()

  _flush: (cb) ->
    this.fn this.contents, (err, data) =>
      if err
        this.emit "error", err
      else
        this.push data
      cb()

module.exports = Async2TransformStream
