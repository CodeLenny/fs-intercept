chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = Promise.promisifyAll require "fs.extra"

Async2TransformStream = require "#{__dirname}/../stream-utils/Async2TransformStream"

ToLowerCase = (str, cb) ->
  Promise
    .delay 1
    .then ->
      cb null, str.toLowerCase()

describe "Using Async2TransformStream with fs", ->

  before ->
    fs.mkdirpAsync "#{__dirname}/tmp"
      .then ->
        Promise.all [
          fs.writeFileAsync "#{__dirname}/tmp/input.txt", "HELLO"
        ]

  after ->
    fs.rmrfAsync "#{__dirname}/tmp"

  afterEach ->
    fs.rmrfAsync "#{__dirname}/tmp/output.txt"

  it "should write transformed input", (done) ->
    input = fs.createReadStream "#{__dirname}/tmp/input.txt"
    transform = new Async2TransformStream ToLowerCase
    output = fs.createWriteStream "#{__dirname}/tmp/output.txt"
    input
      .pipe(transform)
      .pipe(output)
      .on "finish", ->
        fs
          .readFileAsync "#{__dirname}/tmp/output.txt", "utf8"
          .then (file) ->
            file.should.equal "hello"
            done()
