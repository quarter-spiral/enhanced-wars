radio = require('radio')
merge = require('merge')
Module = require('Module')

infinity = 1 / 0

class Unit extends Module
  @include lazy: -> require('EventedObject')
  @include lazy: -> require('ObjectWithPosition')

  defaultOptions =
    selected: false

  constructor: (options) ->
    @set(merge(defaultOptions, options))

    radio('ew/game/unit/selected').subscribe (selectedUnit) =>
      @attack(selectedUnit) if @get('selected') and @canAttack(selectedUnit)

      @select(false) if selectedUnit isnt @

    radio('ew/game/map/clicked').subscribe (mapTile) =>
      return unless @get('selected')
      @moveTo(mapTile)

    radio('ew/game/next-turn').subscribe =>
      @set(hp: @specs().hp) if @get('hp') is undefined
      @set(mp: @specs().mp)
      @select(false)

  select: (newState) =>
    stateToSet = newState
    oldState = @get('selected')
    itIsMyTurn = @game().turnManager.currentPlayer().get('faction') is @get('faction')
    if newState is undefined
      newState = itIsMyTurn and !@get('selected')

    @set(selected: newState)
    radio('ew/game/unit/selected').broadcast(@) if (newState and !oldState) or (!itIsMyTurn and stateToSet is undefined)
    radio('ew/game/unit/unselected').broadcast(@) if !newState and oldState

  moveTo: (mapTile) =>
    @select(false)

    map = @get('map')
    return unless map.unitCanReach(@, mapTile)

    movementCost = map.costToReach(@, mapTile)
    mp = @get('mp')
    return if movementCost > mp

    path = map.unitsPathTo(@, mapTile)
    @set(position: mapTile.position(), mp: mp - movementCost, orientation: path[path.length - 1].orientation, move: path)

  canAttack: (enemy) =>
    return false unless enemy
    return false if enemy.get('faction') is @get('faction')

    @distanceTo(enemy) >= @specs().attackRange.min and @distanceTo(enemy) <= @specs().attackRange.max

  attack: (enemy) =>
    return unless @canAttack(enemy)

    Fight = require('Fight')
    fight = new Fight(attacker: @, enemy: enemy)

  die: =>
    @set(dead: true)

  isAlive: =>
    @get('hp') > 0

  canReturnFire: =>
    @specs().returnsFire

  game: =>
    @get('map').get('game')

  tags: =>
    @specs().tags

  isTagged: (tag) =>
    @tags().indexOf(tag) isnt -1

  specs: =>
    @game().ruleSet.unitSpecs[@get('type')]

  costToMoveTo: (tile) =>
    costs = @game().ruleSet.terrainCosts[tile.get('type')]

    unitAtPosition = @get('map').unitAt(tile.position())
    return infinity if unitAtPosition and unitAtPosition.get('faction') isnt @get('faction')

    cost = null
    cost = costs[tag] for tag in @tags() when costs[tag] and (!cost or costs[tag] > cost)
    cost || costs.default

  distanceTo: (enemy) =>
    Math.abs(@position().x - enemy.position().x) + Math.abs(@position().y - enemy.position().y)

  player: =>
    faction = @get('faction')
    @game().players.detect (player) -> player.get('faction') is faction


exports Unit