chai = require "chai"
should = chai.should()

InterceptRule = require "../InterceptRule"

decache = require "decache"
{fsBackup, restoreFS} = require "./utils"

describe "interceptSuccess", ->

  interceptor = null

  beforeEach ->
    decache "../FSReadInterceptor"
    FSReadInterceptor = require "../FSReadInterceptor"
    interceptor = new FSReadInterceptor()

  afterEach ->
    interceptor.bypass()
    restoreFS()

  describe "interceptSuccess=false", ->

    it "shouldn't run if file found", (done) ->

      class NoInterceptSuccess extends InterceptRule
        intercept: -> yes
        interceptSuccess: no
        readFile: ->
          should.fail "readFile shouldn't be called if file found"
        readFileAlways: ->
          should.fail "readFileAlways shouldn't run in interceptSuccess=false"

      interceptor.use new NoInterceptSuccess()
      interceptor.intercept()
      require("fs").readFile "#{__dirname}/coffeescript-interceptor/test.js", "utf8", (err, data) ->
        done()

  describe "interceptSuccess=true", ->

    it "should run if file found", (done) ->

      called = no

      class InterceptSuccessExists extends InterceptRule
        intercept: -> yes
        interceptSuccess: yes
        readFile: ->
          should.fail "readFile shouldn't be called if file found"
        readFileAlways: (data, file, options, cb) ->
          called = yes
          cb null, data

      interceptor.use new InterceptSuccessExists()
      interceptor.intercept()
      require("fs").readFile "#{__dirname}/coffeescript-interceptor/test.js", "utf8", (err, data) ->
        called.should.equal yes
        done()

    it "should run if file not found", (done) ->

      [readCalled, alwaysCalled] = [no, no]

      class InterceptSuccessReadFile extends InterceptRule
        interceptSuccess: yes
        intercept: -> yes
        readFile: (file, options, cb) ->
          alwaysCalled.should.equal no
          readCalled = yes
          cb null, "DATA"
        readFileAlways: (data, file, options, cb) ->
          readCalled.should.equal yes
          data.should.equal "DATA"
          alwaysCalled = yes
          cb null, data.toLowerCase()

      interceptor.use new InterceptSuccessReadFile()
      interceptor.intercept()
      require("fs").readFile "#{__dirname}/coffeescript-interceptor/test2.js", "utf8", (err, data) ->
        data.should.equal "data"
        alwaysCalled.should.equal yes
        done()
