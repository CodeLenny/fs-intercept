stream = require "stream"

###
Offers an alternative stream source in case a primary stream fails.
###
class ReadableStreamBackup extends stream.Readable

  ###
  @param {ReadableStream} original the primary stream to provide
  @param {Function} backup a function that provides a backup {ReadableStream}, used if `original` experiences an error.
  ###
  constructor: (@original, @backup, opts) ->
    super opts

    @contents = ""

    @original.on "error", (err) =>
      @originalError = err
      replacement = @backup()
      replacement.on "error", (err) =>
        @emit "error", @originalError
      replacement.on "data", (data) =>
        @push data
      replacement.on "end", =>
        @push null

    @original.on "data", (buffer) =>
      @contents += buffer.toString()

    @original.on "end", =>
      return if @originalError
      @push @contents
      @push null

  _read: ->

module.exports = ReadableStreamBackup
