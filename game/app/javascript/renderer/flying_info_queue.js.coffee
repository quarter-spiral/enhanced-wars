class FlyingInfoQueue
  constructor: (@options) ->
    @queue = []
    @game = @options.game
    delete @options.game

  add: (text) =>
    return unless @game.isAtLastAction()
    @queue.push text
    @trigger()

  trigger: =>
    return if @queue.length < 1 or @triggerTimeout
    newElement = @queue.shift()
    FlyingInfo = require("FlyingInfo")
    new FlyingInfo(newElement, @options)
    @triggerTimeout = setTimeout(@timeout, 150 + Math.random() * 50)

  timeout: =>
    delete @triggerTimeout
    @trigger()

exports 'FlyingInfoQueue', FlyingInfoQueue