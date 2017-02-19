###
Describes a pattern of files to intercept.
###
class InterceptRule

  ###
  @property {Boolean} If `false`, this rule is only checked when a file fails to be read.  If `true`, the intercept is
  checked even after a file is successfully found.
  ###
  interceptSuccess: no

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

  ###
  If {InterceptRule#interceptSuccess} is `true`, `readFileAlways` is called after a successful read.
  @param {String, Buffer} data the contents of the file
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @param {Function} callback `(err, data)`
  ###
  readFileAlways: (data, options, callback) -> cb null, data

module.exports = InterceptRule
