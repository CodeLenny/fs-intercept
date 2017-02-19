chai = require "chai"
should = chai.should()

decache = require "decache"

fsBackup = Object.assign {}, require "fs"

restoreFS = ->
  for own k, v of fsBackup
    try
      Object.assign require("fs").k = v
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

  it "stores the global 'readFile'", ->
    interceptor = new FSReadInterceptor()
    interceptor.backup.readFile.should.equal fsBackup.readFile
