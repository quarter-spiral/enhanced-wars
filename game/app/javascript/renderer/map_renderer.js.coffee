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
  desert: ['map/terrain/dessert_0.png', 'map/terrain/dessert_1.png', 'map/terrain/dessert_2.png']
  factory: ['map/terrain/factory.png']
  forrest: ['map/terrain/forrest_0.png', 'map/terrain/forrest_1.png', 'map/terrain/forrest_2.png']
  pineforrest: ['map/terrain/needle_0.png', 'map/terrain/needle_1.png', 'map/terrain/needle_2.png']
  mountain: ['map/terrain/mountain_0.png', 'map/terrain/mountain_1.png', 'map/terrain/mountain_2.png', 'map/terrain/mountain_3.png']
  plain: ['map/terrain/plain_0.png', 'map/terrain/plain_1.png']
  shallowwater: ['map/terrain/shallowwater.png']
  road: ['map/terrain/road_horizontal.png', 'map/terrain/road_vertical.png', 'map/terrain/road_left_down.png', 'map/terrain/road_left_up.png', 'map/terrain/road_right_up.png', 'map/terrain/road_right_down.png', 'map/terrain/road_cross.png']

DROP_ZONE_TILES =
  neutral: ['map/building/dropzone_neutral.png']
  0: ['map/building/dropzone_faction_0.png']
  1: ['map/building/dropzone_faction_1.png']

class Layer
  constructor: (@renderer, @entity) ->
    @actor = new CAAT.Foundation.Actor()
    @setupImage()

  setupImage: =>
    image_id = @imagePool[@type()][@variant()]

    director = @renderer.gameRenderer.director
    @image = new CAAT.SpriteImage().initialize(director.getImage(image_id), 1, 1)

    @actor.setBackgroundImage(@image)
    @actor.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height)

  type: => @entity.type
  variant: => @entity.variant || 0

class TerrainLayer extends Layer
  imagePool: TILE_TYPES

class DropZoneLayer extends Layer
  imagePool: DROP_ZONE_TILES

  constructor: (@renderer, @entity) ->
    super
    @entity.bindProperty 'faction', @setupImage

  type: =>
    if @entity.get('faction') is null then 'neutral' else @entity.get('faction')
  variant: =>  @entity.get('variant') || 0

class Tile
  constructor: (@renderer, @tile) ->
    @container = new CAAT.Foundation.ActorContainer()

    @container.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height)
    @container.scaleTX = 0
    @container.scaleTY = 0
    @container.setScale(TILE_SCALE.width, TILE_SCALE.height)
    @container.setGlobalAlpha true

    {x,y} = @tile.position()
    @container.setLocation(
        x * TILE_DIMENSIONS.width * TILE_SCALE.width + (x * TILE_OFFSET.x),
        y * TILE_DIMENSIONS.height * TILE_SCALE.height + (y * TILE_OFFSET.y)
    )
    @container.tile = @tile

    for layer in @tile.get('layers')
      @container.addChild(new TerrainLayer(@renderer, layer).actor)

    if dropZone = @tile.get('dropZone')
      @container.addChild(new DropZoneLayer(@renderer, dropZone).actor)

    @darkener = new CAAT.Foundation.Actor()
        .setFillStyle('#000000')
        .setAlpha(0.6)
        .setSize(@container.width + (TILE_OFFSET.x / TILE_SCALE.width), @container.height + (TILE_OFFSET.y / TILE_SCALE.height))
        .setVisible(false)
    @container.addChild(@darkener)

    radio('ew/game/unit/unselected').subscribe (unit) =>
      @darkener.setVisible(false)


exports class MapRenderer extends require('Renderer')
  assets: [
    "/assets/terrain/base.png"
    "/assets/terrain/deepwater.png"
    "/assets/terrain/dessert_0.png"
    "/assets/terrain/dessert_1.png"
    "/assets/terrain/dessert_2.png"
    "/assets/terrain/factory.png"
    "/assets/terrain/forrest_0.png"
    "/assets/terrain/forrest_1.png"
    "/assets/terrain/forrest_2.png"
    "/assets/terrain/needle_0.png"
    "/assets/terrain/needle_1.png"
    "/assets/terrain/needle_2.png"
    "/assets/terrain/mountain_0.png"
    "/assets/terrain/mountain_1.png"
    "/assets/terrain/mountain_2.png"
    "/assets/terrain/mountain_3.png"
    "/assets/terrain/plain_0.png"
    "/assets/terrain/plain_1.png"
    "/assets/terrain/shallowwater.png"
    "/assets/terrain/road_cross.png"
    "/assets/terrain/road_horizontal.png"
    "/assets/terrain/road_vertical.png"
    "/assets/terrain/road_left_down.png"
    "/assets/terrain/road_left_up.png"
    "/assets/terrain/road_right_down.png"
    "/assets/terrain/road_right_up.png"
    "/assets/building/dropzone_faction_0.png"
    "/assets/building/dropzone_faction_1.png"
    "/assets/building/dropzone_neutral.png"
  ]

  id: "map"

  constructor: ->
    super

    renderer = @
    radio('ew/game/map/load').subscribe ->
      renderer.loadMap(renderer.game.map)

    radio('ew/renderer/assets-loaded').subscribe (renderer, images) ->
      renderer.loadMap(renderer.map) if renderer.map

    radio('ew/game/unit/selected').subscribe (unit) =>
      return unless unit.get('selected')
      @map.eachTile (mapTile) =>
        enemy = @map.unitAt(mapTile.position())
        rendererTile = @tiles[mapTile.position().y][mapTile.position().x]
        rendererTile.darkener.setVisible(!mapTile.canBeReachedBy(unit) and (!unit.canAttack(enemy) or !unit.hasEnoughApToAttack()))

    @TILE_OFFSET = TILE_OFFSET

  loadMap: (map) =>
    @map = map
    return map unless @ready

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

    radio('ew/game/map/loaded').broadcast()

  screenToMapCoordinates: (screenCoordinates) =>
    x: Math.floor((screenCoordinates.x + TILE_OFFSET.x) / (TILE_DIMENSIONS.width * TILE_SCALE.width + TILE_OFFSET.x))
    y: Math.floor((screenCoordinates.y + TILE_OFFSET.y) / (TILE_DIMENSIONS.height * TILE_SCALE.height + TILE_OFFSET.y))

  click: (e) ->
    tile = @tiles[e.tile.y][e.tile.x]
    return true unless tile
    radio('ew/input/map/clicked').broadcast(tile.tile)
    false
