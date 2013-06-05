clone = require('clone')
Module = require('Module')
EventedObject = require('EventedObject')

exports class Map extends Module
  @include EventedObject

  constructor: (options) ->
    @set(options)
    @set(height: @get('tiles').length, width: @get('tiles')[0].length)

  dimensions: =>
    width: @get('width')
    height: @get('height')

  tileAt: (x, y) =>
    @get('tiles')[y][x]

  eachTile: (fn) =>
    y = 0
    for row in @get('tiles')
      x = 0
      for tile in row
        fn.call(@, tile)
        x++
      y++