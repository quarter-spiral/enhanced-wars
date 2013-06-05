radio = require('radio')

class Game
  AP_PER_TURN: 20

  constructor: ->
    GameRenderer = require('GameRenderer')
    MapEditMapImporter = require('MapEditMapImporter')
    Player = require('Player')
    TurnManager = require('TurnManager')

    new GameRenderer(@)

    @players = [
      new Player(faction: 0, color: '#a2c88e')
      new Player(faction: 1, color: '#aa7092')
    ]

    @turnManager = new TurnManager(@players)

    json = require('dummy-map')
    imported = new MapEditMapImporter(json)

    @map   = imported.map
    @units = imported.units

    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      setTimeout(->
        radio('ew/game/map/load').broadcast()
      , 1000)

    radio('ew/input/unit/clicked').subscribe @unitClicked
    radio('ew/input/map/clicked').subscribe @mapClicked

  unitClicked: (unit) =>
    radio('ew/game/unit/selected').broadcast(unit)

  mapClicked: (mapTile) =>
    radio('ew/game/map/clicked').broadcast(mapTile)

exports Game