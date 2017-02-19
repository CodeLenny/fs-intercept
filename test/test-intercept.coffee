chai = require "chai"
should = chai.should()

CoffeeScriptInterceptor = require "./coffeescript-interceptor/CoffeeScriptInterceptor"

decache = require "decache"
{fsBackup, restoreFS} = require "./utils"

describe "FSReadInterceptor#intercept", ->

  interceptor = null

  beforeEach ->
    decache "../FSReadInterceptor"
    FSReadInterceptor = require "../FSReadInterceptor"
    interceptor = new FSReadInterceptor()

  afterEach ->
    interceptor.bypass()
    require("fs").readFile.should.equal fsBackup.readFile
    restoreFS()

  it "should replace fs.readFile", ->
    require("fs").readFile.should.equal fsBackup.readFile
    interceptor.intercept()
    require("fs").readFile.should.not.equal fsBackup.readFile
