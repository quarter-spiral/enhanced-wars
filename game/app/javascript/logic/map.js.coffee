clone = require('clone')
radio = require('radio')
Module = require('Module')
EventedObject = require('EventedObject')

exports class Map extends Module
  @include EventedObject

  initialize: (options) =>
    @MoveableTiles = require('MoveableTiles')

    @set(options)
    @set(height: @get('tiles').length, width: @get('tiles')[0].length)

    radio('ew/game/next-turn').subscribe =>
      @moveableTiles = null

  dimensions: =>
    width: @get('width')
    height: @get('height')

  tileAt: (x, y) =>
    {x,y} = x unless y

    @get('tiles')[y][x]

  eachTile: (fn) =>
    y = 0
    for row in @get('tiles')
      x = 0
      for tile in row
        fn.call(@, tile)
        x++
      y++

  unitAt: (x, y) =>
    {x,y} = x unless y
    @get('game').units.detect (unit) -> unit.isAtPosition(x: x, y: y)

  unitCanReach: (unit, mapTile) =>
    @costToReach(unit, mapTile) isnt null

  costToReach: (unit, mapTile) =>
    cost = @moveableTilesFor(unit).tiles.detect (e) -> e.tile is mapTile
    return null unless cost
    cost.cost

  moveableTilesFor: (unit) =>
    return @moveableTiles if @moveableTiles and @moveableTiles.unit is unit and unit.isAtPosition(@moveableTiles.position)

    @moveableTiles = new @MoveableTiles(@, unit)

  unitsPathTo: (unit, mapTile) =>
    @moveableTilesFor(unit).pathTo(mapTile)
