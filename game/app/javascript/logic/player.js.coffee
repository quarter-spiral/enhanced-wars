Module = require('Module')
radio = require('radio')

exports class Player extends Module
  @include lazy: -> require('EventedObject')

  constructor: (options) ->
    @set(options)

    @set(points: 0)

    radio('ew/game/next-turn').subscribe =>
      @set(ap: @get('game').ruleSet.apPerTurn)

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
    unit = new Unit(type: unitType, faction: @get('faction'), orientation: 'down', position: game.activeDropZone.position(), map: game.map)
    game.addUnit(unit)
    @set(ap: @get('ap') - @apToCreateUnit(unitType))
    radio('ew/game/unit/bought').broadcast(unit)

  canBuy: (unitType) ->
    @get('ap') >= @apToCreateUnit(unitType)

  apToCreateUnit: (unitType) =>
    @get('game').ruleSet.unitSpecs[unitType].costs.create

  scorePoints: (points) =>
    newPoints = @get('points') + points
    pointsForWin = @get('game').ruleSet.pointsForWin
    if newPoints >= pointsForWin
      newPoints = pointsForWin
      radio('ew/game/won').broadcast(@)

    @set(points: newPoints)