chai = require "chai"
should = chai.should()

decache = require "decache"
{fsBackup, restoreFS} = require "./utils"

describe "FSReadInterceptor#intercept", ->

  interceptor = null

  beforeEach ->
    decache "../FSReadInterceptor"
    FSReadInterceptor = require "../FSReadInterceptor"
    interceptor = new FSReadInterceptor()
    interceptor.methods.length.should.be.above 3

  afterEach ->
    interceptor.bypass()
    require("fs").readFile.should.equal fsBackup.readFile
    restoreFS()

  for property in  require("../FSReadInterceptor")::methods
    do (property) ->
      it "should replace fs.#{property}", ->
        require("fs")[property].should.equal fsBackup[property]
        interceptor.intercept()
        require("fs")[property].should.not.equal fsBackup[property]
