winston = require('winston')

class Task
  constructor: (@connection) ->

  run: (callback) ->
    callback()

  log: (message, level = 'info') ->
    winston.log(level, message)

module.exports = Task