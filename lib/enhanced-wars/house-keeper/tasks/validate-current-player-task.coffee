rules = require('../rules.coffee')

Task = require('../task.coffee').Task

class Match
  constructor: (@uuid, @data) ->

  playerByIndex: (index) =>
    @objectKeys(@data.players)[index]

  numberOfPlayers: =>
    return 0 unless @data.players
    @objectSize(@data.players)

  objectKeys: (object) =>
    k for k,v of object

  objectValues: (object) =>
    v for k,v of object

  objectSize: (object) =>
    @objectValues(object).length

  actualCurrentPlayer: =>
    return null if @numberOfPlayers() < 1

    return 'ended' for score in @actualPoints() when score >= rules.pointsForWin

    forfeit = false
    @eachAction 'ForfeitAction', ->
      forfeit = true
    return 'ended' if forfeit

    playerIndex = @actualCurrentPlayerIndex()

    return 'open-invitation' if playerIndex >= @objectSize(@data.players)

    @playerByIndex(playerIndex)

  actualCurrentPlayerIndex: =>
    currentPlayerIndex = 0
    @eachAction 'NextTurnAction', -> currentPlayerIndex += 1

    currentPlayerIndex % @data.maxPlayers

  actualPoints: =>
    points = []
    points.push(0) while points.length < @data.maxPlayers

    @eachAction (actionUuid, actionData) ->
      if actionData.arguments and actionData.arguments[0] and actionData.arguments[0].pointsAfter
        points = actionData.arguments[0].pointsAfter

    points

  eachAction: (actionClass, callback) =>
    if typeof actionClass is 'function' and !callback
      callback = actionClass
      actionClass = null

    for actionUuid, actionData of @data.actions when !actionClass or actionData.action.actionClass is actionClass
      callback(actionUuid, actionData.action)

  isCurrentPlayerSetCorrectly: =>
    @data.currentPlayer is @actualCurrentPlayer()

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