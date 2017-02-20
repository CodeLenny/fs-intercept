chai = require "chai"
should = chai.should()

decache = require "decache"
CoffeeScriptInterceptor = require "./coffeescript-interceptor/CoffeeScriptInterceptor"

describe "automatic readFileSync", ->

  interceptor = null

  beforeEach ->
    decache "../FSReadInterceptor"
    FSReadInterceptor = require "../FSReadInterceptor"
    interceptor = new FSReadInterceptor()
    interceptor.use new CoffeeScriptInterceptor()
    interceptor.intercept()

  afterEach ->
    interceptor.bypass()

  it "shouldn't intercept existing files", ->
    js = require("fs").readFileSync "#{__dirname}/coffeescript-interceptor/test.js", "utf8"
    js.should.include "JavaScript"

  it "should compile CoffeeScript if file doesn't exist", ->
    js = require("fs").readFileSync "#{__dirname}/coffeescript-interceptor/test2.js", "utf8"
    js.should.be.a.string
    js.should.include "CoffeeScript"
    js.should.include "/*"
    js.should.not.include "#"

  it "should throw error if file isn't found", ->
    (-> require("fs").readFileSync "#{__dirname}/coffeescript-interceptor/invalid.js", "utf8").should.throw()
