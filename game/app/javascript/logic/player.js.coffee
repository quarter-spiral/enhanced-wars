Module = require('Module')
radio = require('radio')

class Player extends Module
  @include lazy: -> require('EventedObject')

  constructor: (options) ->
    @set(options)

    @set(points: 0)

    radio('ew/game/next-turn').subscribe =>
      @set(ap: @get('game').ruleSet.apPerTurn, fired: false, streak: 0)

    radio('ew/game/kill').subscribe ({attacker, enemy, bullet}) =>
      if attacker.player() is @
        newStreak = @get('streak') + 1
        @set(streak: newStreak)
        @scorePoints(@get('game').ruleSet.rewards.streak(newStreak))
        radio('ew/game/streak').broadcast(streakValue: newStreak)

    @get('game').onready =>
      game = @get('game')
      game.map.eachTile (tile) =>
        if dropZone = tile.get('dropZone')
          dropZone.bindProperty 'faction', (changedValues) =>
            @scorePoints(game.ruleSet.rewards.captureDropZone) if changedValues.faction.new is @get('faction')

  deductAp: (ap) ->
    @set(ap: @get('ap') - ap)

  buyUnit: (unitType) =>
    return unless @canBuy(unitType)
    Unit = require('Unit')
    game = @get('game')
    unitCreationOptions = {type: unitType, faction: @get('faction'), orientation: 'down', position: game.activeDropZone.position(), map: game.map}
    unit = new Unit(unitCreationOptions)
    unit.set(mp: 0, fired: true)
    game.addUnit(unit)
    apCost = @apToCreateUnit(unitType)
    @deductAp(apCost)
    radio('ew/game/unit/added-to-player').broadcast(unit)

    BuyUnitAction = require('BuyUnitAction')
    actionOptions = require('merge')(unitCreationOptions, apCost: apCost)
    delete actionOptions.map
    @get('game').addAction new BuyUnitAction(actionOptions)

  canBuy: (unitType) ->
    @get('ap') >= @apToCreateUnit(unitType)

  apToCreateUnit: (unitType) =>
    @get('game').ruleSet.unitSpecs[unitType].costs.create

  forfeit: =>
    @set(forfeit: true)
    radio('ew/game/forfeit').broadcast(@)
    ForfeitAction = require('ForfeitAction')
    @get('game').addAction new ForfeitAction(playerUuid: @get('uuid'))
    radio('ew/game/won').broadcast(@get('game').winner())

  won: =>
    return true if @get('game').players.length < 3 and @get('game').players.filter((e) => e.get('forfeit') and e isnt @).length > 0

    pointsForWin = @get('game').ruleSet.pointsForWin
    @get('points') >= pointsForWin

  scorePoints: (points) =>
    newPoints = @get('points') + points
    pointsForWin = @get('game').ruleSet.pointsForWin
    @set(points: newPoints)

    if newPoints >= pointsForWin
      newPoints = pointsForWin
      radio('ew/game/won').broadcast(@)

    radio('ew/game/pointsScored').broadcast()

exports 'Player', Player