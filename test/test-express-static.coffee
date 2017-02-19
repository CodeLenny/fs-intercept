chai = require "chai"
chaiHTTP = require "chai-http"
chai.use chaiHTTP
should = chai.should()

decache = require "decache"
CoffeeScriptInterceptor = require "./coffeescript-interceptor/CoffeeScriptInterceptor"
express = require "express"

{fsBackup, restoreFS} = require "./utils"

describe "Integration: express.static()", ->

  [interceptor, app] = []

  before ->
    decache "../FSReadInterceptor"
    FSReadInterceptor = require "../FSReadInterceptor"
    interceptor = new FSReadInterceptor()
    interceptor.use new CoffeeScriptInterceptor()
    interceptor.intercept()
    app = express()
    app.use express.static "#{__dirname}/express-static"

  after ->
    interceptor.bypass()
    restoreFS()

  it "should serve regular files", ->
    chai
      .request app
      .get "/plain.html"
      .then (res) ->
        res.should.have.status 200
        res.should.be.html
        res.text.should.include "HTML"

  it "should serve existing JavaScript files", ->
    chai
      .request app
      .get "/test.js"
      .buffer()
      .then (res) ->
        res.should.have.status 200
        res.text.should.include "JavaScript"

  it.skip "should serve compiled CoffeeScript files", ->
    chai
      .request app
      .get "/test2.js"
      .buffer()
      .then (res) ->
        res.should.have.status 200
        res.text.should.include "CoffeeScript"
        res.text.should.include "/*"
        res.text.should.not.include "#"
