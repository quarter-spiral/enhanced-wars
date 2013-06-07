radio = require('radio')
Module = require('Module')

exports class MapTile extends Module
  @include lazy: -> require('EventedObject')
  @include lazy: -> require('ObjectWithPosition')

  constructor: (options) ->
    @set(options)

  neighbors: =>
    {x,y} = @position()
    neighbors = []
    map = @get('map')

    # neighbor to the West
    neighbors.push map.tileAt(x - 1, y) if x > 0

    # neighbor to the East
    neighbors.push map.tileAt(x + 1, y) if x < map.dimensions().width - 1

    # neighbor to the North
    neighbors.push map.tileAt(x, y - 1) if y > 0

    # neighbor to the South
    neighbors.push map.tileAt(x, y + 1) if y < map.dimensions().height - 1

    neighbors

  canBeReachedBy: (unit) =>
    @get('map').unitCanReach(unit, @)