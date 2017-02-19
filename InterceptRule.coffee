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
  @param {String} method the `fs` method being called, e.g. `"readFile"`
  @param {Array} params the parameters provided to the `fs` call.
  @return {Boolean} if `true`, the file read will be intercepted by this rule.
  ###
  intercept: (method, params) -> no

  ###
  A replacement `fs.readFile` to run on intercepted files.
  @param {String, Buffer, Integer} file the file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @param {Function} callback `(err, data)`
  ###
  readFile: (file, options, callback) -> callback new TypeError "InterceptRule hasn't defined a 'readFile' method."

  ###
  A replacement `fs.stat` to return when files are intercepted.
  @param {String, Buffer} path
  @param {Function} callback `(err, stats)`
  ###
  stat: (path, callback) -> callback new TypeError "InterceptRule hasn't defined a 'stats' method."

  ###
  If {InterceptRule#interceptSuccess} is `true`, `readFileAlways` is called after a successful read.
  @param {String, Buffer, Integer} file the original file path requested
  @param {Object, String} options the options passed
  @option options {String, Null} encoding
  @option options {String} flag
  @param {String, Buffer} data the contents of the file
  @param {Function} callback `(err, data)`
  ###
  readFileAlways: (file, options, data, callback) -> cb null, data

module.exports = InterceptRule
