radio = require('radio')
merge = require('merge')
Module = require('Module')

class Unit extends Module
  @include lazy: -> require('EventedObject')
  @include lazy: -> require('ObjectWithPosition')

  defaultOptions =
    selected: false

  constructor: (options) ->
    @set(merge(defaultOptions, options))

    radio('ew/game/unit/selected').subscribe (unit) =>
      @set(selected: unit is @ and !@get('selected'))

    radio('ew/game/map/clicked').subscribe (mapTile) =>
      return unless @get('selected')
      @set(selected: false, position: mapTile.position())

exports Unit