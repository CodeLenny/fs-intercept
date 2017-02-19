chai = require "chai"
should = chai.should()

CoffeeScriptInterceptor = require "./coffeescript-interceptor/CoffeeScriptInterceptor"

decache = require "decache"
{restoreFS} = require "./utils"

describe "FSReadInterceptor Basic Interception", ->

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

  it "shouldn't intercept existing files", (done) ->
    require("fs").readFile "#{__dirname}/coffeescript-interceptor/test.js", "utf8", (err, js) ->
      should.not.exist err
      js.should.include "JavaScript"
      done()

  it "should compile CoffeeScript if file doesn't exist", (done) ->
    require("fs").readFile "#{__dirname}/coffeescript-interceptor/test2.js", "utf8", (err, js) ->
      should.not.exist err
      js.should.be.a.string
      js.should.include "CoffeeScript"
      js.should.include "/*"
      js.should.not.include "#"
      done()
