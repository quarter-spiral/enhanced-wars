clone = require('clone')

exports class Map
  constructor: ->

  eachTile: (fn) =>
    y = 0
    for row in @tiles
      x = 0
      for tile in row
        tile = clone(tile)
        tile.x = x
        tile.y = y
        fn.call(@, tile)
        x++
      y++