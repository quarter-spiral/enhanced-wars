Task = require('../task.coffee').Task

class PruneChatTask extends Task
  id: 'prune-chat'
  run: (callback) =>
    setTimeout =>
      @log("PRUNING CHAT")
      callback()
    , 500

module.exports = PruneChatTask