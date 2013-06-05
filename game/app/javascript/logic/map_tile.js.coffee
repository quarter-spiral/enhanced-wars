radio = require('radio')
Module = require('Module')

exports class MapTile extends Module
  @include lazy: -> require('EventedObject')
  @include lazy: -> require('ObjectWithPosition')

  constructor: (options) ->
    @set(options)