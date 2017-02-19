###
Intercepts calls to `fs.readFileAsync`, preforming transformations and other actions.
###
class FSReadInterceptor

  ###
  @property {Array<InterceptRule>} The loaded modules that will be used to intercept file reads.
  ###
  intercepts: null

  ###
  @property {Object} stores a copy of the unmodified `readFile`
  ###
  backup: null

  ###
  @param {Object} opts overrides any local parameters.
  ###
  constructor: (opts = {})->
    Object.assign @, opts
    @intercepts ?= []
    @backup ?= {}
    @backup.readFile ?= require("fs").readFile

module.exports = FSReadInterceptor
