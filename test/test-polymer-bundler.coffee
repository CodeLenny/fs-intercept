chai = require "chai"
should = chai.should()

FSReadInterceptor = require "../FSReadInterceptor"
CoffeeScriptInterceptor = require "./coffeescript-interceptor/CoffeeScriptInterceptor"
BladeInterceptor = require "./blade-interceptor/BladeInterceptor"

describe "Integration: Polymer Bundler", ->

  [interceptor, bundle, html] = []

  file = "#{__dirname}/polymer-bundler/entry.html"

  before ->
    interceptor = new FSReadInterceptor()
    interceptor.use new CoffeeScriptInterceptor()
    interceptor.use new BladeInterceptor()
    interceptor.intercept()
    {Bundler} = require "polymer-bundler"
    bundler = new Bundler
      inlineScripts: yes
    bundler
      .bundle [file]
      .then (b) ->
        bundle = b
        html = require("parse5").serialize bundle.get(file).ast

  after ->
    interceptor.bypass()

  it "should include 'imported.html'", ->
    bundle.get(file).files.should.include "#{__dirname}/polymer-bundler/imported.html"

  it "should include the entrypoint Blade", ->
    html.should.include 'id="EntryPoint"'

  it "should include CoffeeScript", ->
    html.should.include "/*"
    html.should.include "Imported CoffeeScript"

  it "should include Blade files", ->
    html.should.include 'id="ImportedBlade"'
