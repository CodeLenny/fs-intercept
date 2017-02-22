FSReadInterceptor = require "./FSReadInterceptor"
CoffeeScriptInterceptor = require "./test/coffeescript-interceptor/CoffeeScriptInterceptor"

interceptor = new FSReadInterceptor()
interceptor.use new CoffeeScriptInterceptor()
interceptor.intercept()

Promise = require "bluebird"
fs = Promise.promisifyAll require "fs.extra"

compileCoffee = (js) ->
  fs
    .rmrfAsync "#{__dirname}/#{js}.js"
    .then ->
      fs.readFileAsync "#{__dirname}/#{js}.js", "utf8"
    .then (src) ->
      fs.writeFileAsync "#{__dirname}/#{js}.js", src

task "compile", "Compile source files", ->
  Promise.all [
    compileCoffee "FSReadInterceptor"
    compileCoffee "InterceptRule"
  ]
