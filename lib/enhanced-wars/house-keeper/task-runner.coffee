fs = require('fs')
winston = require('winston')

class TaskRunner
  tasksDir: __dirname + '/tasks/'

  constructor: (@connection) ->
    @initTasks()

  run: (callback) =>
    unless @tasksReady
      curriedRun = => @run(callback)
      setTimeout(curriedRun, 1000)
      return

    runningTasks = []

    for taskId, task of @tasks
      winston.info("Starting task: #{taskId}")
      runningTasks.push taskId
      task.run =>
        runningTasks.splice(runningTasks.indexOf(taskId), 1)
        callback() if runningTasks.length < 1
      winston.info("Finished task: #{taskId}")

  initTasks: ->
    @tasks = {}
    fs.readdir @tasksDir, (err,files) =>
      throw err if err
      files.forEach (file) =>
        taskClass = require(@tasksDir + file)
        task = new taskClass(@connection)
        @tasks[task.id] = task
      @tasksReady = true

module.exports =
  TaskRunner: TaskRunner