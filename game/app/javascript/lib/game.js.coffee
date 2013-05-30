class Game
  constructor: ->
    radio = require('radio')
    GameRenderer = require('GameRenderer')
    MapEditMapImporter = require('MapEditMapImporter')

    new GameRenderer(@)

    json = require('dummy-map')
    map = MapEditMapImporter.import(json)

    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      setTimeout(->
        radio('ew/game/map/load').broadcast(map)
      , 1000)

exports Game