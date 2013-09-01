Task = require('../task.coffee')

class PruneChatTask extends Task
  MAX_MESSAGES = parseInt(process.env.QS_MAX_PUBLIC_CHAT_MESSAGES || 250, 10)
  MAX_MESSAGE_THRESHOLD = parseInt(process.env.QS_MAX_PUBLIC_CHAT_MESSAGES_THRESHOLD || 20, 10)

  id: 'prune-chat'

  run: (callback) =>
    @pruneChat(callback)

  pruneChat: (callback) =>
    messageRef = @connection.refs.publicChatMessages
    return callack() unless messageRef

    messageRef.once 'value', (snapshot) =>
      existingMessages = snapshot.numChildren()
      messagesToPrune = existingMessages - MAX_MESSAGES

      if messagesToPrune < MAX_MESSAGE_THRESHOLD + 1
        callback()
        return

      @log("Pruning #{messagesToPrune} public chat messages")
      pruningCount = 0
      pruningDone = false
      messageRef.once 'value', (snapshot) =>
        snapshot.forEach (snapshot) =>
          snapshot.ref().remove =>
            if pruningDone
              @log("Pruning done.")
              callback()
          pruningCount += 1
          pruningDone = pruningCount is messagesToPrune

module.exports = PruneChatTask