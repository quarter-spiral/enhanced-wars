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

    @container.setSize(TILE_DIMENSIONS.width * TILE_SCALE.width, TILE_DIMENSIONS.height * TILE_SCALE.height)
    @container.scaleTX = 0
    @container.scaleTY = 0
    @container.setScale(TILE_SCALE.width, TILE_SCALE.height)

    {x,y} = @tile.position()
    @container.setLocation(
        x * TILE_DIMENSIONS.width * TILE_SCALE.width + (x * TILE_OFFSET.x),
        y * TILE_DIMENSIONS.height * TILE_SCALE.height + (y * TILE_OFFSET.y)
    )
    @container.tile = @tile

    for layer in @tile.get('layers')
      @container.addChild(new Layer(@renderer, layer).actor)

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
        map.dimensions().width * TILE_DIMENSIONS.width * TILE_SCALE.width + (map.dimensions().width * TILE_OFFSET.x),
        map.dimensions().height * TILE_DIMENSIONS.height * TILE_SCALE.height + (map.dimensions().height * TILE_OFFSET.y)
    )

    self = @
    @tiles = {}
    map.eachTile (mapTile) ->
      tile = new Tile(self, mapTile)
      {x,y} = mapTile.position()
      self.tiles[y] ||= {}
      self.tiles[y][x] = tile
      self.container.addChild(tile.container)

    @container.cacheAsBitmap(0, CAAT.Foundation.Actor.CACHE_SIMPLE)

    radio('ew/game/map/loaded').broadcast()

  screenToMapCoordinates: (screenCoordinates) =>
    x: Math.floor((screenCoordinates.x + TILE_OFFSET.x) / (TILE_DIMENSIONS.width * TILE_SCALE.width + TILE_OFFSET.x))
    y: Math.floor((screenCoordinates.y + TILE_OFFSET.y) / (TILE_DIMENSIONS.height * TILE_SCALE.height + TILE_OFFSET.y))

  click: (e) ->
    tile = @tiles[e.tile.y][e.tile.x]
    return true unless tile
    radio('ew/input/map/clicked').broadcast(tile.tile)
    false
