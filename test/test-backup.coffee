chai = require "chai"
should = chai.should()

decache = require "decache"

fsBackup = Object.assign {}, require "fs"

restoreFS = ->
  for own k, v of fsBackup
    try
      require("fs")[k] = v
    catch err
      yes

describe "FSReadInterceptor.backup", ->

  FSReadInterceptor = null

  beforeEach ->
    decache "../FSReadInterceptor"
    FSReadInterceptor = require "../FSReadInterceptor"
    restoreFS()

  afterEach ->
    restoreFS()
    require("fs").readFile.should.be.a.function
    require("fs").readFile.should.equal fsBackup.readFile

  it "stores the global `readFile`", ->
    interceptor = new FSReadInterceptor()
    interceptor.backup.readFile.should.equal fsBackup.readFile

  it "stores the global `stat`", ->
    interceptor = new FSReadInterceptor()
    interceptor.backup.stat.should.equal fsBackup.stat

  it "persists even if `fs` changed", ->
    interceptor = new FSReadInterceptor()
    require("fs").readFile = null
    interceptor.backup.readFile.should.equal fsBackup.readFile
