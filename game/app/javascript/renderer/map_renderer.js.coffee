radio = require('radio')

TILE_DIMENSIONS =
  width:  128
  height: 150

TILE_SCALE = {
  width: 0.5
  height: 0.5
}

TILE_OFFSET = {
  x: 0
  y: -16
}

TILE_TYPES =
  base: ['map/base.png']
  deepwater: ['map/deepwater.png']
  desert: ['map/dessert_0.png', 'map/dessert_1.png']
  factory: ['map/factory.png']
  forrest: ['map/forrest_0.png']
  mountain: ['map/mountain_0.png']
  plain: ['map/plain_0.png']
  shallowwater: ['map/shallowwater.png']

class Layer
  constructor: (@renderer, @layer) ->
    image_id = TILE_TYPES[@layer.type][@layer.variant || 0]

    director = renderer.renderer.director
    @image = new CAAT.SpriteImage().initialize(director.getImage(image_id), 1, 1)

    @actor = new CAAT.Foundation.Actor()
    @actor.setBackgroundImage(@image)
    @actor.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height)

class Tile
  constructor: (@renderer, @tile) ->
    @container = new CAAT.Foundation.ActorContainer()

    @container.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height)
    @container.setScale(TILE_SCALE.width, TILE_SCALE.height)

    @container.setLocation(
        @tile.x * TILE_DIMENSIONS.width * TILE_SCALE.width + (@tile.x * TILE_OFFSET.x),
        @tile.y * TILE_DIMENSIONS.height * TILE_SCALE.height + (@tile.y * TILE_OFFSET.y)
    )

    for layer in @tile
      @container.addChild(new Layer(@renderer, layer).actor)

    @container.cacheAsBitmap()

scrollMap = (renderer, newEvent) ->
  oldEvent = renderer.mouseDragEvent
  return unless oldEvent

  xDiff = oldEvent.x - newEvent.x
  yDiff = oldEvent.y - newEvent.y
  x = renderer.container.x - xDiff
  y = renderer.container.y - yDiff
  minX = -1 * (renderer.container.width - renderer.renderer.scene.width)
  maxX = 0
  x = minX if x < minX
  x = maxX if x > maxX
  minY = -1 * (renderer.container.height - renderer.renderer.scene.height) + 180
  maxY = 0
  y = minY if y < minY
  y = maxY if y > maxY
  renderer.container.setPosition(x, y)

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

    scroller = new CAAT.Foundation.Actor()
    scroller.setBounds(0, 0, @renderer.scene.width, @renderer.scene.height)
    scroller.mouseDrag = (e) ->
      scrollMap(renderer, e)
      renderer.mouseDragEvent = e
    scroller.mouseUp = (e) ->
      scrollMap(renderer, e)
    @renderer.scene.addChild(scroller)

  loadMap: (map) =>
    return @map = map unless @ready

    @container.emptyChildren()
    @container.setLocation(0, 0)
    @container.setSize(
        map.width * TILE_DIMENSIONS.width * TILE_SCALE.width,
        map.height * TILE_DIMENSIONS.height * TILE_SCALE.height
    )

    self = @
    map.eachTile (tile) ->
      self.container.addChild(new Tile(self, tile).container)
