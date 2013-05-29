radio = require('radio')

TILE_DIMENSIONS =
  width:  128 / 2
  height: 150 / 2

TILE_TYPES =
  base: ['map/base.png']
  deepwater: ['map/deepwater.png']
  desert: ['map/dessert_0.png', 'map/dessert_1.png']
  factory: ['map/factory.png']
  forrest: ['map/forrest_0.png']
  mountain: ['map/mountain_0.png']
  plain: ['map/plain_0.png']
  shallowwater: ['map/shallowwater.png']


layerToActor = (renderer, layer) ->
  image_id = TILE_TYPES[layer.type][layer.variant || 0]
  image = new CAAT.SpriteImage().initialize(renderer.renderer.director.getImage(image_id), 1, 1)

  actor = new CAAT.Foundation.Actor()
  actor.setBackgroundImage(image, true)
  actor.setScale(TILE_DIMENSIONS.width / (1.0 * image.width), TILE_DIMENSIONS.height / (image.height * 1.0))
  actor

scrollMap = (renderer, newEvent) ->
  oldEvent = renderer.mouseDragEvent
  return unless oldEvent

  xDiff = oldEvent.x - newEvent.x
  yDiff = oldEvent.y - newEvent.y
  x = renderer.actors.x - xDiff
  y = renderer.actors.y - yDiff
  minX = -1 * (renderer.actors.width - renderer.renderer.scene.width)
  maxX = 0
  x = minX if x < minX
  x = maxX if x > maxX
  minY = -1 * (renderer.actors.height - renderer.renderer.scene.height) + 180
  maxY = 0
  y = minY if y < minY
  y = maxY if y > maxY
  renderer.actors.setPosition(x, y)

  renderer.mouseDragEvent = null

exports class MapRenderer extends require('Renderer')
  assets: [
    "/assets/terrain/base.png"
    "/assets/terrain/deepwater.png"
    "/assets/terrain/dessert_0.png"
    "/assets/terrain/dessert_1.png"
    "/assets/terrain/factory.png"
    "/assets/terrain/forrest_0.png"
    "/assets/terrain/mountain_0.png"
    "/assets/terrain/plain_0.png"
    "/assets/terrain/shallowwater.png"
  ]

  id: "map"

  constructor: ->
    super

    renderer = @
    radio('ew/game/map/load').subscribe(@loadMap)
    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      renderer.loadMap(renderer.map) if renderer.map

    adjuster = new CAAT.Foundation.ActorContainer();
    adjuster.setPosition(-32, -48);
    @renderer.scene.addChild(adjuster)
    @actors.setParent(adjuster)

    @actors.setPosition(0, 0)
    @actors.setGestureEnabled(true)
    scroller = new CAAT.Foundation.Actor()
    scroller.setBounds(0, 0, @renderer.scene.width, @renderer.scene.height)
    scroller.mouseDrag = (e) ->
      scrollMap(renderer, e)
      renderer.mouseDragEvent = e
    scroller.mouseUp = (e) ->
      scrollMap(renderer, e)
    @renderer.scene.addChild(scroller)

  loadMap: (map) =>
    unless @ready
      @map = map
      return

    @actors.emptyChildren()
    @actors.setSize(map.width * TILE_DIMENSIONS.width, map.height * TILE_DIMENSIONS.height)

    y = 0
    for row in map.tiles
      x = 0
      for spot in row
        for layer in spot
          actor = layerToActor(@, layer)
          yOffset = (y * 16)
          actor.setPosition(x * TILE_DIMENSIONS.width, y * TILE_DIMENSIONS.height - yOffset)
          @actors.addChild(actor)
        x++
      y++