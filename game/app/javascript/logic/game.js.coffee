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
    radio('ew/input/actions/seek').subscribe @seekToAction

    @init(options.map)

  init: (mapData, @actions = []) =>
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

    @currentAction = -1
    radio('ew/game/actions/updated').broadcast(@)

  selectedUnit: =>
    @units.detect (u) -> u.get('selected')

  addUnit: (unit) =>
    @units.push unit
    unit.bindProperty 'dead', (changedValues) =>
      @units = @units.filter (u) -> u.isAlive()
    radio('ew/game/unit/added').broadcast(unit)

  addAction: (action) =>
    @actions.push action
    radio('ew/game/actions/updated').broadcast(@, action)
    @currentAction = @actions.length - 1

  seekToAction: (actionIndex) =>
    while actionIndex > @currentAction
      @currentAction += 1
      @actions[@currentAction].perform(@)
    while actionIndex < @currentAction
      @actions[@currentAction].reverse(@)
      @currentAction -= 1

  isAtLastAction: =>
    (@currentAction is @actions.length - 1) or (@currentAction is 0 and @actions.length is 0)

  dumpPoints: =>
    player.get('points') for player in @players

  dumpStreaks: =>
    player.get('streak') for player in @players

  setPoints: (points) =>
    player.set(points: points.shift()) for player in @players

  onready: (callback) =>
     return callback.apply(@) if @ready
     @loadQueue.push callback

  unitClicked: (unit) =>
    return unless @isAtLastAction()
    unit.select()

  mapClicked: (mapTile) =>
    radio('ew/game/map/clicked').broadcast(mapTile)

  toggleDebug: =>
    jQuery = require('jquery')
    jQuery('body').toggleClass('ew-debug')

exports Game