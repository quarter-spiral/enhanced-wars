var ObjectHelper = require('./object-helper')

class Match
  constructor: (@uuid, @data) ->

  playerByIndex: (index) =>
    ObjectHelper.keys(@data.players)[index]

  numberOfPlayers: =>
    return 0 unless @data.players
    ObjectHelper.size(@data.players)

  actualCurrentPlayer: =>
    return null if @numberOfPlayers() < 1

    return 'ended' for score in @actualPoints() when score >= rules.pointsForWin

    forfeit = false
    @eachAction 'ForfeitAction', ->
      forfeit = true
    return 'ended' if forfeit

    playerIndex = @actualCurrentPlayerIndex()

    return 'open-invitation' if playerIndex >= ObjectHelper.size(@data.players)

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

  lastAction: (playerUuid) =>
    currentPlayer = 0

    @eachAction (actionUuid, action) =>
      if action.actionClass is 'NextTurnAction'
        currentPlayer += 1
      else


  eachAction: (actionClass, callback) =>
    if typeof actionClass is 'function' and !callback
      callback = actionClass
      actionClass = null

    for actionUuid, actionData of @data.actions when !actionClass or actionData.action.actionClass is actionClass
      callback(actionUuid, actionData.action)

  isCurrentPlayerSetCorrectly: =>
    @data.currentPlayer is @actualCurrentPlayer()

module.exports = Match