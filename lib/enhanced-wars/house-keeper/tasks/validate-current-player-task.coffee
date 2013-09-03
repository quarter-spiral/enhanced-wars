Task = require('../task.coffee').Task

Match = require('./match')

class ValidateCurrentPlayerTask extends Task
  id: 'validate-current-player'

  constructor: (@connection) ->
    @connection.on 'matchDataChanged', (event) => @checkAndRepairMatch(event.data...)

  run: (callback) =>
    @checkAndRepairMatch(matchUuid, matchData) for matchUuid, matchData of @connection.matchData
    callback()

  checkAndRepairMatch: (matchUuid, matchData) =>
    return unless matchData
    match = new Match(matchUuid, matchData)
    @fixCurrentPlayer(match) unless match.isCurrentPlayerSetCorrectly()

  fixCurrentPlayer: (match) =>
    @log("Reparing match: #{match.uuid}. Setting currentPlayer from #{match.data.currentPlayer} to #{match.actualCurrentPlayer()}")
    @connection.refs.matchData.child(match.uuid).child('currentPlayer').set(match.actualCurrentPlayer())

module.exports = ValidateCurrentPlayerTask