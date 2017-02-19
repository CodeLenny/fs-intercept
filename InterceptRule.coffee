###
Describes a pattern of files to intercept.
###
class InterceptRule

  ###
  @property {Boolean} If `false`, this rule is only checked when a file is failed to be read.  If `true`, intercept rule
    is run all file reads, even if the file exists.
  ###
  interceptAll: no

  ###
  Determine if the given file should be intercepted by this rule.
  @param {String, Buffer, Integer} path the file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @return {Boolean} if `true`, the file read will be intercepted by this rule.
  ###
  intercept: (path, options) -> no

  ###
  A replacement `fs.readFile` to run on intercepted files.
  @param {String, Buffer, Integer} path the file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @param {Function} callback `(err, data)`
  ###
  readFile: (path, options, callback) -> yes

module.exports = InterceptRule
