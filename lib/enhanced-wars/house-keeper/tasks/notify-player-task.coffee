Task = require('../task.coffee')
Task = require('./match.coffee')
ObjectHelper = require('./object-helper.coffee')

class NotifyPlayerTask extends Task
  id: 'notify-player'

  run: (callback) =>
    @checkNotifications(callback)

  checkForPendingNotifications: (callback) =>
    jobCount = ObjectHelper.size(@connection.matchData)

    jobDone = ->
      jobDone -= 1
      callback() if jobCount < 1

    @sendNotificationsFor(matchUuid, matchData, jobDone) for matchUuid, matchData of @connection.matchData

  sendNotificationsFor: (matchUuid, matchData, callback) =>
    match = new Match(matchUuid, matchData)

    currentPlayer = match.actualCurrentPlayer()
    lastAction = match.lastActionOf(currentPlayer)
    console.log(currentPlayer, lastAction.timestamp)

module.exports = PruneChatTask