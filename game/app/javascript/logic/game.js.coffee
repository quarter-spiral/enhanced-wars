radio = require('radio')

class Game
  loadQueue: [],

  constructor: (options)->
    GameRenderer = require('GameRenderer')

    @gameRenderer = new GameRenderer(@)

    if (!window.localStorage) or (window.localStorage.getItem("EWRules") is undefined) or (window.localStorage.getItem("EWRules") is null)
      DefaultRuleSet = require('DefaultRuleSet')
      @ruleSet = new DefaultRuleSet()
    else
      eval(window.localStorage.getItem("EWRules"));
      LocalRuleSet = require('LocalRuleSet')
      @ruleSet = LocalRuleSet

    radio('ew/game/next-turn').subscribe =>
      @activeDropZone = null
    radio('ew/game/shop/close').subscribe =>
      @activeDropZone = null

    radio('ew/input/unit/clicked').subscribe @unitClicked
    radio('ew/input/map/clicked').subscribe @mapClicked

    @init(options.map)

  init: (mapData) =>
    Player = require('Player')
    MapEditMapImporter = require('MapEditMapImporter')
    TurnManager = require('TurnManager')

    @players = [
      new Player(faction: 0, color: '#a2c88e', game: @)
      new Player(faction: 1, color: '#aa7092', game: @)
    ]
    @turnManager ||= new TurnManager()
    @turnManager.init(@players)

    imported = new MapEditMapImporter(mapData, @)
    @map   = imported.map
    @units = []
    @addUnit(unit) for unit in imported.units

    if @assetsLoaded
      radio('ew/game/map/load').broadcast()
    else
      radio("ew/renderer/assets-loaded").subscribe (renderer, images) =>
        @assetsLoaded = true
        setTimeout(->
          radio('ew/game/map/load').broadcast()
        , 1000)

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

  toggleDebug: =>
    jQuery = require('jquery')
    jQuery('body').toggleClass('ew-debug')

exports Game