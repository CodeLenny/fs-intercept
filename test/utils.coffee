exports.fsBackup = fsBackup = Object.assign {}, require "fs"

exports.restoreFS = restoreFS = ->
  for own k, v of fsBackup
    try
      Object.assign require("fs")[k] = v
    catch err
      yes
