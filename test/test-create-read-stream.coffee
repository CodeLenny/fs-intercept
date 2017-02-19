chai = require "chai"
should = chai.should()

CoffeeScriptInterceptor = require "./coffeescript-interceptor/CoffeeScriptInterceptor"

decache = require "decache"
{restoreFS} = require "./utils"

describe "FSReadInterceptor#interceptedCreateReadStream", ->

  interceptor = null

  beforeEach ->
    decache "../FSReadInterceptor"
    FSReadInterceptor = require "../FSReadInterceptor"
    interceptor = new FSReadInterceptor()
    interceptor.use new CoffeeScriptInterceptor()
    interceptor.intercept()

  afterEach ->
    interceptor.bypass()
    restoreFS()

  describe "given an existing file", ->
    it "should return a stream", (done) ->
      stream = require("fs").createReadStream "#{__dirname}/coffeescript-interceptor/test.js"
      stream.should.be.an.instanceof require("stream").Readable
      stream.on "data", -> yes
      stream.on "end", done

    it "should stream the contents", (done) ->
      contents = ""
      stream = require("fs").createReadStream "#{__dirname}/coffeescript-interceptor/test.js"
      stream.on "data", (buff) -> contents += buff.toString()
      stream.on "error", (err) -> throw err
      stream.on "end", ->
        contents.should.include "JavaScript"
        done()

  describe "given CoffeeScript to compile", ->
    it "should return a stream", (done) ->
      stream = require("fs").createReadStream "#{__dirname}/coffeescript-interceptor/test2.js"
      stream.should.be.an.instanceof require("stream").Readable
      stream.on "data", -> yes
      stream.on "end", done

    it "should stream the contents", (done) ->
      contents = ""
      stream = require("fs").createReadStream "#{__dirname}/coffeescript-interceptor/test2.js"
      stream.on "data", (buff) -> contents += buff.toString()
      stream.on "end", ->
        contents.should.include "CoffeeScript"
        contents.should.include "/*"
        contents.should.not.include "#"
        done()
