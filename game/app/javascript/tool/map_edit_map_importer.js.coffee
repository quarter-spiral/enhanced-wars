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
  constructor: (mapEditData) ->
    Map  = require('Map')
    MapTile  = require('MapTile')
    Unit = require('Unit')

    tiles = []
    units = []
    for column in mapEditData
      for spot in column
        adjustMapSize(tiles, spot)

        type = tileTypeFor(spot)
        layers = [type: type, variant: spot.terrainVariant]
        tiles[spot.y][spot.x] = new MapTile(position: spot, type: type, layers: layers)

        if unitType = unitTypeFor(spot)
          unit = new Unit(type: unitType, faction: spot.unitFaction, orientation: spot.unitOrientation, position: spot)
          units.push unit

    @units = units

    @map = new Map(tiles: tiles)