radio = require('radio')

exports class TurnManager
  constructor: (@players) ->

  currentPlayer: =>
    @players[@turn]

  nextTurn: =>
    turn = @turn + 1
    turn = 0 if turn >= @players.length
    @setTurn(turn)

  setTurn: (turn) ->
    @turn = turn
    radio('ew/game/next-turn').broadcast(@)
    @turn
