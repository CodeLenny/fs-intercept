chai = require "chai"
should = chai.should()

FSReadInterceptor = require "../FSReadInterceptor"
CoffeeScriptInterceptor = require "./coffeescript-interceptor/CoffeeScriptInterceptor"

describe "Integration: browserify", ->

  for from in ["coffee", "js"]
    for to in ["coffee", "js"]
      do (from, to) ->
        describe "requiring #{to} from #{from}", ->

          interceptor = null
          contents = ""

          before (done) ->
            interceptor = new FSReadInterceptor()
            interceptor.use new CoffeeScriptInterceptor()
            interceptor.intercept()
            plain = if from is "js" then "-plain" else ""
            browserify = require "browserify"
            instance = browserify "#{__dirname}/browserify/require-#{to}#{plain}.js"
            instance.bundle (err, buff) ->
              throw err if err
              contents = buff.toString()
              done()

          after ->
            interceptor.bypass()

          if from is "coffee"
            it "should compile the parent CoffeeScript", ->
              contents.should.include "CoffeeScript parent"
              contents.should.include "/*"
              contents.should.not.include "#"
          else
            it "should include the parent JavaScript", ->
              contents.should.include "JavaScript parent"

          if to is "coffee"
            it "should compile the required CoffeeScript", ->
              contents.should.include "Required CoffeeScript"
          else
            it "should include the required JavaScript", ->
              contents.should.include "Required JavaScript"
