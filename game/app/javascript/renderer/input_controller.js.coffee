radio = require('radio')

exports class InputController
  constructor: (scene) ->
    startDragEvent = null

    scrollMap = (newEvent) ->
      return unless startDragEvent

      diff =
        x: startDragEvent.x - newEvent.x
        y: startDragEvent.y - newEvent.y

      radio('ew/input/scrollMap').broadcast(diff)
      startDragEvent = null

    @controller = new CAAT.Foundation.Actor()
    @controller.setBounds(0, 0, scene.width, scene.height)
    scene.addChild(@controller)

    @controller.mouseDrag = (e) ->
      scrollMap(e)
      startDragEvent = e
    @controller.mouseUp = (e) ->
      scrollMap(e)