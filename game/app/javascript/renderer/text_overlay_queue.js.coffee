exports class TextOverlayQueue
  constructor: (@parent) ->
    @queue = []

  add: (text) =>
    @queue.push text
    @trigger()

  trigger: =>
    return if @queue.length < 1 or @triggerTimeout
    newElement = @queue.shift()
    TextOverlay = require('textOverlay')
    new TextOverlay(@parent,newElement)
    @triggerTimeout = setTimeout(@timeout, 350)

  timeout: =>
    delete @triggerTimeout
    @trigger()
