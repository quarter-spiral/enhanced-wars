TILE_TYPES =
  none: 'base'
  dessert: 'desert'
  deepWater: 'deepwater'
  shallowWater: 'shallowwater'

UNIT_TYPES =
  none: null
  heavyTank: 'heavytank'
  lightTank: 'lighttank'
  mediumArtillery: 'mediumartillery'
  mediumTank: 'mediumtank'
  spiderBot: 'spiderbot'

tileTypeFor = (spot) ->
  TILE_TYPES[spot.terrain] || spot.terrain

unitTypeFor = (spot) ->
  UNIT_TYPES[spot.unit]

adjustMapSize = (tiles, spot) ->
  tiles.push([]) while tiles.length <= spot.y
  tiles[spot.y].push([]) while tiles[spot.y].length <= spot.x

exports class MapEditMapImporter
  constructor: (mapEditData, game) ->
    Map  = require('Map')
    MapTile  = require('MapTile')
    Unit = require('Unit')

    tiles = []
    units = []
    @map = new Map()
    for column in mapEditData.data
      for spot in column
        adjustMapSize(tiles, spot)

        type = tileTypeFor(spot)
        layers = [type: type, variant: spot.terrainVariant]
        tiles[spot.y][spot.x] = new MapTile(position: spot, type: type, layers: layers, map: @map)

        if unitType = unitTypeFor(spot)
          unit = new Unit(type: unitType, faction: spot.unitFaction, orientation: spot.unitOrientation, position: spot, map: @map)
          units.push unit

    @units = units

    @map.initialize(game: game, tiles: tiles)