Module = require('Module')
radio = require('radio')

exports class Player extends Module
  @include lazy: -> require('EventedObject')

  constructor: (options) ->
    @set(options)

    radio('ew/game/next-turn').subscribe =>
      @set(ap: @get('game').ruleSet.apPerTurn)

  deductAp: (ap) ->
    @set(ap: @get('ap') - ap)