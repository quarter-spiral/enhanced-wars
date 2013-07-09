radio = require('radio')

exports class TurnManager
  init: (@players) ->

  currentPlayer: =>
    @players[@turn]

  nextTurn: =>
    turn = @turn + 1
    turn = 0 if turn >= @players.length
    @setTurn(turn)

  previousTurn: =>
    turn = @turn - 1
    turn = @players.length - 1 if turn < 0
    @setTurn(turn)

  setTurn: (turn) ->
    @turn = turn
    radio('ew/game/next-turn').broadcast(@)
    @turn