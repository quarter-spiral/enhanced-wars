radio = require('radio')

class Game
  loadQueue: [],

  constructor: (options)->
    mapToLoad = options.map

    if mapToLoad
      $ = require('jquery')
      mapUrl = "https://mapEdit.firebaseio.com/v2/maps/#{mapToLoad}.json"

      self = @
      $.ajax(url: mapUrl, dataType: 'jsonp').
          done((data) ->
            self.init(data.map)
          ).
          fail(->
            console.log("could not load map :/", mapToLoad)
          )
    else
      json = require('dummy-map')
      @init(json)

  init: (mapData) =>
    GameRenderer = require('GameRenderer')

    Player = require('Player')
    TurnManager = require('TurnManager')
    DefaultRuleSet = require('DefaultRuleSet')
    MapEditMapImporter = require('MapEditMapImporter')

    @gameRenderer = new GameRenderer(@)

    @players = [
      new Player(faction: 0, color: '#a2c88e', game: @)
      new Player(faction: 1, color: '#aa7092', game: @)
    ]

    @turnManager = new TurnManager(@players)

    @ruleSet = new DefaultRuleSet()

    imported = new MapEditMapImporter(mapData, @)
    @map   = imported.map
    @units = []
    @addUnit(unit) for unit in imported.units


    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      setTimeout(->
        radio('ew/game/map/load').broadcast()
      , 1000)

    radio('ew/game/next-turn').subscribe =>
      @activeDropZone = null
    radio('ew/game/shop/close').subscribe =>
      @activeDropZone = null

    radio('ew/input/unit/clicked').subscribe @unitClicked
    radio('ew/input/map/clicked').subscribe @mapClicked

    @turnManager.setTurn(0)

    callback.apply(@) for callback in @loadQueue
    @ready = true

  selectedUnit: =>
    @units.detect (u) -> u.get('selected')

  addUnit: (unit) =>
    @units.push unit
    unit.bindProperty 'dead', (changedValues) =>
      @units = @units.filter (u) -> u.isAlive()
    radio('ew/game/unit/added').broadcast(unit)

  onready: (callback) =>
     return callback.apply(@) if @ready
     @loadQueue.push callback

  unitClicked: (unit) =>
    unit.select()

  mapClicked: (mapTile) =>
    radio('ew/game/map/clicked').broadcast(mapTile)

exports Game