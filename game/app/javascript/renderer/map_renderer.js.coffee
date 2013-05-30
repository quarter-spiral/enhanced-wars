radio = require('radio')
clone = require('clone')

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

class ScrollController
  constructor: (@renderer) ->
    startDragEvent = null

    scrollMap = (newEvent) ->
      return unless startDragEvent

      diff =
        x: startDragEvent.x - newEvent.x
        y: startDragEvent.y - newEvent.y

      radio('ew/input/scrollMap').broadcast(diff)
      startDragEvent = null

    @controller = new CAAT.Foundation.Actor()
    @controller.setBounds(0, 0, @renderer.renderer.director.width, @renderer.renderer.director.height)

    @controller.mouseDrag = (e) ->
      scrollMap(e)
      startDragEvent = e
    @controller.mouseUp = (e) ->
      scrollMap(e)

class ScrollHandler
  constructor: (@renderer) ->
    radio('ew/input/scrollMap').subscribe @scrollMap
    @reset()

  reset: =>
    @minimum =
      x: -1 * (@renderer.container.width - @renderer.renderer.scene.width) + TILE_OFFSET.x
      y: -1 * (@renderer.container.height - @renderer.renderer.scene.height) + TILE_OFFSET.y

    @maximum =
      x: TILE_OFFSET.x
      y: TILE_OFFSET.y

  scrollMap: (diff) =>
    newPosition =
      x: @renderer.container.x - diff.x
      y: @renderer.container.y - diff.y

    newPosition = @toBounds(newPosition)
    @renderer.container.setPosition(newPosition.x, newPosition.y)

  toBounds: (position) =>
    position = clone(position)
    position.x = @minimum.x if position.x < @minimum.x
    position.x = @maximum.x if position.x > @maximum.x

    position.y = @minimum.y if position.y < @minimum.y
    position.y = @maximum.y if position.y > @maximum.y

    position

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

    radio('ew/renderer/assets-loaded').subscribe (renderer, images) ->
      renderer.loadMap(renderer.map) if renderer.map

    @renderer.scene.addChild(new ScrollController(renderer).controller)
    @scrollHandler = new ScrollHandler(@)

  loadMap: (map) =>
    return @map = map unless @ready

    @container.emptyChildren()
    @container.setLocation(TILE_OFFSET.x, TILE_OFFSET.y)
    @container.setSize(
        map.width * TILE_DIMENSIONS.width * TILE_SCALE.width + (map.width * TILE_OFFSET.x),
        map.height * TILE_DIMENSIONS.height * TILE_SCALE.height + (map.height * TILE_OFFSET.y)
    )
    @scrollHandler.reset()

    self = @
    map.eachTile (tile) ->
      self.container.addChild(new Tile(self, tile).container)
