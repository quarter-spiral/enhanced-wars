MapEditMapImporter =
  import: (mapEditData) ->
    Map = require('Map')

    map = new Map()
    tiles = []

    x = 0
    while x < mapEditData.length
      y = 0
      while y < mapEditData[x].length
        tiles.push([]) if tiles.length <= y

        spot = mapEditData[x][y]
        type = spot.terrain

        type = 'base' if type == 'none'
        type = 'desert' if type == 'dessert'

        tiles[y][x] = [type: type, variant: 0]
        y++
      x++

    map.tiles = tiles
    map.height = tiles.length
    map.width = tiles[0].length

    map

exports 'MapEditMapImporter', MapEditMapImporter