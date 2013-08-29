winston = require('winston')

class Task
  constructor: (@connection) ->

  log: (message, level = 'info') ->
    winston.log(level, message)

module.exports = {
  Task: Task
}