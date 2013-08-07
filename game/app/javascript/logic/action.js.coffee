radio = require('radio')

radio('ew/time-control/adjust-score').subscribe (game, points) ->
  game.setPoints(points.slice(0))

class Action
  constructor: ->
    @arguments = arguments
  dump: ->
    {actionClass: @actionClass, arguments: @arguments}

Action.load = (dump) ->
  actionClass = require(dump.actionClass)
  new actionClass(dump.arguments[0])

exports Action

class MoveAction extends Action
  actionClass: 'MoveAction'
  constructor: ({@from, @to, @mpCost, @apCost, @oldOrientation, @newOrientation, @capturedZones, @pointsBefore, @pointsAfter}) ->
    super

  perform: (game) =>
    game.turnManager.currentPlayer().deductAp(@apCost)

    unit = game.map.unitAt(@from)
    newMp = unit.get('mp') - @mpCost
    unit.set(position: @to, mp: newMp, orientation: @newOrientation)

    if @capturedZones
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

    if @capturedZones
      for capture in @capturedZones
        dropZone = game.map.tileAt(capture.tile).get('dropZone')
        dropZone.capturedBy(capture.oldFaction || null)
      radio('ew/time-control/adjust-score').broadcast(game, @pointsBefore)

exports MoveAction

class BuyUnitAction extends Action
  actionClass: 'BuyUnitAction'
  constructor: ({@position, @type, @faction, @orientation, @apCost}) ->
    super

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
  actionClass: 'NextTurnAction'
  constructor: ({@apBefore}) ->
    super

  perform: (game) =>
    game.turnManager.nextTurn()

  reverse: (game) =>
    game.turnManager.previousTurn()
    game.turnManager.currentPlayer().set(ap: @apBefore)

exports NextTurnAction

class FightAction extends Action
  actionClass: 'FightAction'
  constructor: ({@unitsBefore, @unitsAfter, @streakBefore, @streakAfter, @apCost, @pointsBefore, @pointsAfter, @playersFiredBefore, @playersFiredAfter}) ->
    super

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
      unit.fireProperty('hp')

    radio('ew/time-control/adjust-score').broadcast(game, @pointsAfter)

exports FightAction

class ForfeitAction extends Action
  actionClass: 'ForfeitAction'
  constructor: ({@playerUuid}) ->
    super

  perform: (game) =>
    player = (game.players.detect (e) => e.get('uuid') is @playerUuid)
    return unless player
    player.set(forfeit: true)
    radio('ew/game/forfeit').broadcast(player)
    radio('ew/game/won').broadcast(player.get('game').winner())

  reverse: (game) =>
    player = (game.players.detect (e) => e.get('uuid') is @playerUuid)
    return unless player
    player.set(forfeit: false)

exports ForfeitAction