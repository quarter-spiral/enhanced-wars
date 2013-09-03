rules = require('../rules.coffee')

ObjectHelper = require('./object-helper')

class Match
  constructor: (@uuid, @data) ->

  playerByIndex: (index) =>
    @data.players[index % @data.maxPlayers]

  numberOfPlayers: =>
    return 0 unless @data.players
    @data.players.length

  actualCurrentPlayer: =>
    return null if @numberOfPlayers() < 1

    return 'ended' for score in @actualPoints() when score >= rules.pointsForWin

    forfeit = false
    @eachAction 'ForfeitAction', ->
      forfeit = true
    return 'ended' if forfeit

    playerIndex = @actualCurrentPlayerIndex()

    return 'open-invitation' if playerIndex >= @data.players.length

    @playerByIndex(playerIndex)

  actualCurrentPlayerIndex: =>
    currentPlayerIndex = 0
    @eachAction 'NextTurnAction', -> currentPlayerIndex += 1

    currentPlayerIndex % @data.maxPlayers

  turnAtLastEmail: (playerUuid) =>
    return null if !(@data.turnAtLastEmail?)
    @data.turnAtLastEmail[playerUuid]

  actualPoints: =>
    points = []
    points.push(0) while points.length < @data.maxPlayers

    @eachAction (actionUuid, actionData) ->
      if actionData.arguments and actionData.arguments[0] and actionData.arguments[0].pointsAfter
        points = actionData.arguments[0].pointsAfter

    points

  lastActionOf: (playerUuid, callback) =>
    currentPlayer = 0
    lastActions = {}
    actionCount = ObjectHelper.size(@data.actions)
    actionIndex = 0

    @eachAction (actionUuid, action, rawData) =>
      lastActions[@playerByIndex(currentPlayer)] = [action, rawData]

      if action.actionClass is 'NextTurnAction'
        currentPlayer += 1

      callback(lastActions[@playerByIndex(@actualCurrentPlayerIndex())]...) if actionIndex is actionCount - 1
      actionIndex += 1

  eachAction: (actionClass, callback) =>
    if typeof actionClass is 'function' and !callback
      callback = actionClass
      actionClass = null

    actionUuids = ObjectHelper.keys(@data.actions).sort()

    for actionUuid in actionUuids
      actionData = @data.actions[actionUuid]
      if !actionClass or actionData.action.actionClass is actionClass
        callback(actionUuid, actionData.action, actionData)

  isCurrentPlayerSetCorrectly: =>
    @data.currentPlayer is @actualCurrentPlayer()

module.exports = Match