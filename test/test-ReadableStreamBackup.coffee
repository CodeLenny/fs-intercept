chai = require "chai"
should = chai.should()

Promise = require "bluebird"
fs = Promise.promisifyAll require "fs.extra"

ReadableStreamBackup = require "#{__dirname}/../stream-utils/ReadableStreamBackup"

describe "Using ReadableStreamBackup with fs", ->

  before ->
    fs.mkdirpAsync "#{__dirname}/tmp"
      .then ->
        Promise.all [
          fs.writeFileAsync "#{__dirname}/tmp/input.txt", "HELLO"
          fs.writeFileAsync "#{__dirname}/tmp/backup.txt", "backup"
        ]

  after ->
    fs.rmrfAsync "#{__dirname}/tmp"

  afterEach ->
    fs.rmrfAsync "#{__dirname}/tmp/output.txt"

  it "should use valid input", (done) ->
    primary = fs.createReadStream "#{__dirname}/tmp/input.txt"
    backup = new ReadableStreamBackup primary, -> fs.createReadStream "#{__dirname}/tmp/backup.txt"
    backup
      .pipe fs.createWriteStream "#{__dirname}/tmp/output.txt"
      .on "finish", ->
        fs
          .readFileAsync "#{__dirname}/tmp/output.txt", "utf8"
          .then (output) ->
            output.should.equal "HELLO"
            done()

  it "should use the backup for invalid input", (done) ->
    primary = fs.createReadStream "#{__dirname}/tmp/invalid.txt"
    backup = new ReadableStreamBackup primary, -> fs.createReadStream "#{__dirname}/tmp/backup.txt"
    backup
      .pipe fs.createWriteStream "#{__dirname}/tmp/output.txt"
      .on "finish", ->
        fs
          .readFileAsync "#{__dirname}/tmp/output.txt", "utf8"
          .then (output) ->
            output.should.equal "backup"
            done()
