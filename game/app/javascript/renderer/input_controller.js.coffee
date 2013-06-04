radio = require('radio')

exports class InputController
  constructor: (gameRenderer) ->
    startDragEvent = null

    scrollMap = (newEvent) ->
      return unless startDragEvent

      diff =
        x: startDragEvent.x - newEvent.x
        y: startDragEvent.y - newEvent.y

      radio('ew/input/scrollMap').broadcast(diff)
      startDragEvent = null

    @controller = new CAAT.Foundation.Actor()

    scene = gameRenderer.scene
    @controller.setBounds(0, 0, scene.width, scene.height)
    scene.addChild(@controller)

    @controller.mouseDrag = (e) ->
      scrollMap(e)
      startDragEvent = e
    @controller.mouseUp = (e) ->
      scrollMap(e)

    @controller.mouseClick = (e) ->
      ewEvent = {
        modifiers:
          alt: e.alt
          meta: e.meta
          control: e.control
          shift: e.shift
        point:
          x: e.x + gameRenderer.SCENE_OFFSET.x - gameRenderer.renderers.map.container.x
          y: e.y + gameRenderer.SCENE_OFFSET.y - gameRenderer.renderers.map.container.y
        sourceEvent: e.sourceEvent
        rendererEvent: e
      }
      radio('ew/input/click').broadcast(ewEvent)