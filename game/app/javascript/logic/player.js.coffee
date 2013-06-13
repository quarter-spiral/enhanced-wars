Module = require('Module')
radio = require('radio')

exports class Player extends Module
  @include lazy: -> require('EventedObject')

  constructor: (options) ->
    @set(options)

    radio('ew/game/next-turn').subscribe =>
      @set(ap: @get('game').ruleSet.apPerTurn)

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
