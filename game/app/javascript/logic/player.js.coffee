Module = require('Module')

exports class Player extends Module
  @include lazy: -> require('EventedObject')

  constructor: (options) ->
    @set(options)
