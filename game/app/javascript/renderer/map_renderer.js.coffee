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
  base: ['map/terrain/base.png']
  deepwater: ['map/terrain/deepwater.png']
  desert: ['map/terrain/dessert_0.png', 'map/terrain/dessert_1.png']
  factory: ['map/terrain/factory.png']
  forrest: ['map/terrain/forrest_0.png']
  mountain: ['map/terrain/mountain_0.png']
  plain: ['map/terrain/plain_0.png']
  shallowwater: ['map/terrain/shallowwater.png']

class Layer
  constructor: (@renderer, @layer) ->
    image_id = TILE_TYPES[@layer.type][@layer.variant || 0]

    director = @renderer.gameRenderer.director
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
    radio('ew/game/map/load').subscribe ->
      renderer.loadMap(renderer.game.map)

    radio('ew/renderer/assets-loaded').subscribe (renderer, images) ->
      renderer.loadMap(renderer.map) if renderer.map

    @TILE_OFFSET = TILE_OFFSET

  loadMap: (map) =>
    return @map = map unless @ready

    @container.emptyChildren()
    @container.setLocation(TILE_OFFSET.x, TILE_OFFSET.y)
    @container.setSize(
        map.width * TILE_DIMENSIONS.width * TILE_SCALE.width + (map.width * TILE_OFFSET.x),
        map.height * TILE_DIMENSIONS.height * TILE_SCALE.height + (map.height * TILE_OFFSET.y)
    )

    self = @
    map.eachTile (tile) ->
      self.container.addChild(new Tile(self, tile).container)

    @container.cacheAsBitmap(0, CAAT.Foundation.Actor.CACHE_SIMPLE)

    radio('ew/game/map/loaded').broadcast()
