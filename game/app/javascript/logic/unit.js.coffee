radio = require('radio')
Module = require('Module')
EventedObject = require('EventedObject')

class Unit extends Module
  @include EventedObject

  constructor: ({@type, @orientation, @faction, @position}) ->
    radio('ew/game/unit/selected').subscribe (unit) =>
      @set(selected: unit is @ and !@get('selected'))

exports Unit