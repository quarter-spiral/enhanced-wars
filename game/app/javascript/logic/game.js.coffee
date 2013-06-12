radio = require('radio')

class Game
  loadQueue: [],

  constructor: ->
    GameRenderer = require('GameRenderer')
    MapEditMapImporter = require('MapEditMapImporter')
    Player = require('Player')
    TurnManager = require('TurnManager')
    DefaultRuleSet = require('DefaultRuleSet')

    new GameRenderer(@)

    @players = [
      new Player(faction: 0, color: '#a2c88e', game: @)
      new Player(faction: 1, color: '#aa7092', game: @)
    ]

    @turnManager = new TurnManager(@players)

    @ruleSet = new DefaultRuleSet()

    json = require('dummy-map')
    imported = new MapEditMapImporter(json, @)

    @map   = imported.map
    @units = imported.units

    for unit in @units
      unit.bindProperty 'dead', (changedValues) =>
        @units = @units.filter (u) -> u.isAlive()

    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      setTimeout(->
        radio('ew/game/map/load').broadcast()
      , 1000)

    radio('ew/input/unit/clicked').subscribe @unitClicked
    radio('ew/input/map/clicked').subscribe @mapClicked

    @turnManager.setTurn(0)

    callback.apply(@) for callback in @loadQueue
    @ready = true

  onready: (callback) =>
     return callback.apply(@) if @ready
     @loadQueue.push callback

  unitClicked: (unit) =>
    unit.select()

  mapClicked: (mapTile) =>
    radio('ew/game/map/clicked').broadcast(mapTile)

exports Game