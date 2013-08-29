winston = require('winston')

Connection = require('./connection.coffee').Connection
connection = new Connection()

TaskRunner = require('./task-runner.coffee').TaskRunner

onExit = ->
  winston.info("Closing house keeping connections")
  connection.close
  winston.info("House keeping process exited")

process.on 'uncaughtException', (err) ->
  winston.error('Caught house keeping exception: ' + err + "\n" + err.stack)
  process.exit(1)

process.on 'exit', onExit
process.on 'SIGINT', ->
  process.exit(0)

runner = new TaskRunner(connection)
runTasks = ->
  winston.info("Running periodical house keeping tasks...")
  runner.run ->
    winston.info("All house keeping tasks ran.")
    setTimeout(runTasks, 30000)

runTasks()