radio = require('radio')

radio('ew/time-control/adjust-score').subscribe (game, points) ->
  game.setPoints(points.slice(0))

class Action

class MoveAction extends Action
  constructor: ({@from, @to, @mpCost, @apCost, @oldOrientation, @newOrientation, @capturedZones, @pointsBefore, @pointsAfter}) ->

  perform: (game) =>
    game.turnManager.currentPlayer().deductAp(@apCost)

    unit = game.map.unitAt(@from)
    newMp = unit.get('mp') - @mpCost
    unit.set(position: @to, mp: newMp, orientation: @newOrientation)

    for capture in @capturedZones
      dropZone = game.map.tileAt(capture.tile).get('dropZone')
      dropZone.capturedBy(unit.get('faction'))
    radio('ew/time-control/adjust-score').broadcast(game, @pointsAfter)

  reverse: (game) =>
    selectedUnit = game.selectedUnit()
    selectedUnit.select(false) if selectedUnit

    game.turnManager.currentPlayer().deductAp(@apCost * -1)

    unit = game.map.unitAt(@to)
    newMp = unit.get('mp') + @mpCost
    unit.set(position: @from, mp: newMp, orientation: @oldOrientation)

    for capture in @capturedZones
      dropZone = game.map.tileAt(capture.tile).get('dropZone')
      dropZone.capturedBy(capture.oldFaction, reversePoints: unit.get('faction'))
    radio('ew/time-control/adjust-score').broadcast(game, @pointsBefore)

exports MoveAction

class BuyUnitAction extends Action
  constructor: ({@position, @type, @faction, @orientation, @apCost}) ->

  perform: (game) =>
    game.turnManager.currentPlayer().deductAp(@apCost)

    Unit = require('Unit')
    unit = new Unit(type: @type, faction: @faction, orientation: @orientation, position: @position, map: game.map)
    unit.set(mp: 0, fired: true)
    game.addUnit(unit)
    radio('ew/game/unit/added-to-player').broadcast(unit)

  reverse: (game) =>
    game.turnManager.currentPlayer().deductAp(@apCost * -1)
    game.map.unitAt(@position.x, @position.y, onlyAlive: true).die()

exports BuyUnitAction

class NextTurnAction extends Action
  constructor: ({@apBefore}) ->

  perform: (game) =>
    game.turnManager.nextTurn()

  reverse: (game) =>
    game.turnManager.previousTurn()
    game.turnManager.currentPlayer().set(ap: @apBefore)

exports NextTurnAction

class FightAction extends Action
  constructor: ({@unitsBefore, @unitsAfter, @streakBefore, @streakAfter, @apCost, @pointsBefore, @pointsAfter, @playersFiredBefore, @playersFiredAfter}) ->

  perform: (game) =>
    game.turnManager.currentPlayer().deductAp(@apCost)

    playersFired = @playersFiredAfter.splice(0)
    streaks = @streakAfter.splice(0)
    broadcastStreak = null
    for player in game.players
      streak = streaks.shift()
      fired = playersFired.shift()
      player.set(streak: streak, fired: fired)
      broadcastStreak = streak if player is game.turnManager.currentPlayer()
    radio('ew/game/streak').broadcast(streakValue: broadcastStreak)

    for unitOptions in @unitsAfter
      unit = game.map.unitAt(unitOptions.position)
      unit.set(require('clone')(unitOptions.dump))
      unit.die() if !unit.isAlive()

    radio('ew/time-control/adjust-score').broadcast(game, @pointsAfter)

  reverse: (game) =>
    game.turnManager.currentPlayer().deductAp(@apCost * -1)

    clone = require('clone')
    playersFired = @playersFiredBefore.splice(0)
    streaks = @streakBefore.splice(0)
    broadcastStreak = null
    for player in game.players
      streak = streaks.shift()
      fired = playersFired.shift()
      player.set(streak: streak, fired: fired)
      broadcastStreak = streak if player is game.turnManager.currentPlayer()
    radio('ew/game/streak').broadcast(streakValue: broadcastStreak)

    for unitOptions in @unitsBefore
      unit = game.map.unitAt(unitOptions.position)
      unless unit
        Unit = require('Unit')
        unit = new Unit(require('merge')(unitOptions.dump, map: game.map, hp: 9999))
        game.addUnit(unit)
        radio('ew/game/unit/added-to-player').broadcast(unit)

      unit.set(clone(unitOptions.dump))

    radio('ew/time-control/adjust-score').broadcast(game, @pointsAfter)

exports FightAction