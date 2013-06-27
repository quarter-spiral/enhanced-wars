Module = require('Module')
radio = require('radio')

exports class DropZone extends Module
  @include lazy: -> require('EventedObject')
  @include lazy: -> require('ObjectWithPosition')

  constructor: (options) ->
    @set(options)

  capturedBy: (unit) =>
    @set(faction: unit.player().get('faction'))
    radio('ew/game/drope-zone-captured').broadcast()