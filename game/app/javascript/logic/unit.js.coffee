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
      @select(false) if selectedUnit isnt @ and selectedUnit.get('selected')

    radio('ew/game/map/clicked').subscribe (mapTile) =>
      return unless @get('selected')
      @moveTo(mapTile)

    radio('ew/game/next-turn').subscribe =>
      @set(mp: @game().ruleSet.unitSpecs[@get('type')].mp)
      @select(false)

  select: (newState) =>
    if newState is undefined
      itIsMyTurn = @game().turnManager.currentPlayer().get('faction') is @get('faction')
      newState = itIsMyTurn and !@get('selected')

    @set(selected: newState)
    radio('ew/game/unit/selected').broadcast(@)

  moveTo: (mapTile) =>
    @select(false)

    map = @get('map')
    return unless map.unitCanReach(@, mapTile)

    movementCost = map.costToReach(@, mapTile)
    mp = @get('mp')
    return if movementCost > mp

    path = map.unitsPathTo(@, mapTile)
    @set(position: mapTile.position(), mp: mp - movementCost, orientation: path[path.length - 1].orientation)

  game: =>
    @get('map').get('game')

  tags: =>
    @game().ruleSet.unitSpecs[@get('type')].tags

  costToMoveTo: (tile) =>
    costs = @game().ruleSet.terrainCosts[tile.get('type')]

    unitAtPosition = @get('map').unitAt(tile.position())
    return infinity if unitAtPosition and unitAtPosition.get('faction') isnt @get('faction')

    cost = null
    cost = costs[tag] for tag in @tags() when costs[tag] and (!cost or costs[tag] > cost)
    cost || costs.default


exports Unit