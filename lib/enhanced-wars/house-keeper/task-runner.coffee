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
      runningTasks.push taskId

    onDone = (id) =>
      trackId = '' + id
      =>
        winston.info("Finished task: #{trackId  }")
        runningTasks.splice(runningTasks.indexOf(trackId  ), 1)
        callback() if runningTasks.length < 1

    for taskId, task of @tasks
      task.run onDone(taskId)

  initTasks: ->
    @tasks = {}
    fs.readdir @tasksDir, (err,files) =>
      throw err if err
      files.forEach (file) =>
        if file.match(/-task\.coffee$/)
          taskClass = require(@tasksDir + file)
          task = new taskClass(@connection)
          @tasks[task.id] = task
      @tasksReady = true

module.exports =
  TaskRunner: TaskRunner