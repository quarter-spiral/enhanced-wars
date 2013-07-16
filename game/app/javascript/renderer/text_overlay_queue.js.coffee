exports class TextOverlayQueue
  constructor: (@parent, @game) ->
    @queue = []

  add: (text) =>
    return unless @game.isAtLastAction()
    @queue.push text
    @trigger()

  trigger: =>
    return if @queue.length < 1 or @triggerTimeout
    newElement = @queue.shift()
    TextOverlay = require('textOverlay')
    new TextOverlay(@parent,newElement)
    @triggerTimeout = setTimeout(@timeout, 450)

  timeout: =>
    delete @triggerTimeout
    @trigger()
