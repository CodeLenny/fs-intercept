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

  afterEach ->
    interceptor.bypass()
    require("fs").readFile.should.equal fsBackup.readFile
    restoreFS()

  for property in ["readFile", "stat", "createReadStream", "readFileSync"]
    do (property) ->
      it "should replace fs.#{property}", ->
        require("fs")[property].should.equal fsBackup[property]
        interceptor.intercept()
        require("fs")[property].should.not.equal fsBackup[property]
