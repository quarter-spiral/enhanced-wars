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

MAP_FACTOR =
  width: (TILE_DIMENSIONS.width * TILE_SCALE.width + TILE_OFFSET.x) - 2
  height: (TILE_DIMENSIONS.height * TILE_SCALE.height + TILE_OFFSET.y) - 1

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

class DummyTile
  constructor: (@renderer, x, y) ->
    @container = new CAAT.Foundation.ActorContainer()

    director = @renderer.gameRenderer.director
    image = new CAAT.SpriteImage().initialize(director.getImage('map/terrain/base.png'), 1, 1)
    @container.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height).
        setBackgroundImage(image)
    @container.scaleTX = 0
    @container.scaleTY = 0
    @container.setScale(TILE_SCALE.width, TILE_SCALE.height)
    @container.setGlobalAlpha true

    @container.setLocation(
      x * MAP_FACTOR.width
      y * MAP_FACTOR.height
    )

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
    @renderer.cache()

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
        (x + @renderer.border.x) * MAP_FACTOR.width
        (y + @renderer.border.y) * MAP_FACTOR.height
    )
    @container.tile = @tile

    for layer in @tile.get('layers')
      @container.addChild(new TerrainLayer(@renderer, layer).actor)

    if dropZone = @tile.get('dropZone')
      @container.addChild(new DropZoneLayer(@renderer, dropZone).actor)

    @darkener = new CAAT.Foundation.Actor()
        .setFillStyle('#000000')
        .setAlpha(0.6)
        .setSize(@container.width, @container.height-34)
        .setPosition(0, 20)
        .setVisible(false)
    @container.addChild(@darkener)

    radio('ew/game/unit/unselected').subscribe (unit) =>
      @darkener.setVisible(false)
      @renderer.cache()


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

    # highlights tiles that the selected unit can either reach or attack
    radio('ew/game/unit/selected').subscribe (unit) =>
      return unless unit.get('selected')
      @map.eachTile (mapTile) =>
        enemy = @map.unitAt(mapTile.position())
        rendererTile = @tiles[mapTile.position().y][mapTile.position().x]
        rendererTile.darkener.setVisible(!mapTile.canBeReachedBy(unit) and (!unit.canAttack(enemy) or !unit.hasEnoughApToAttack()))
      @cache()

    @TILE_OFFSET = TILE_OFFSET

  loadMap: (map) =>
    @map = map
    return map unless @ready

    @disableCaching = true

    @border =
      x: Math.ceil(((@parent.width * 1.0 / MAP_FACTOR.width) - map.dimensions().width) / 2)
      y: Math.ceil(((@parent.height * 1.0 / MAP_FACTOR.height) - map.dimensions().height) / 2)

    @border.x = 1 if @border.x < 1
    @border.y = 1 if @border.y < 1

    @container.emptyChildren()
    @container.setLocation(TILE_OFFSET.x, TILE_OFFSET.y)

    @container.setSize(
        (map.dimensions().width + (@border.x * 2)) * MAP_FACTOR.width
        (map.dimensions().height + (@border.y * 2)) * MAP_FACTOR.height
    )

    self = @
    @tiles = {}
    map.eachTile (mapTile) ->
      tile = new Tile(self, mapTile)
      {x,y} = mapTile.position()
      self.tiles[y] ||= {}
      self.tiles[y][x] = tile
      self.container.addChild(tile.container)

    for x in [0..map.dimensions().width + (self.border.x * 2)]
      for y in [0...self.border.y]
        dummyTileTop = new DummyTile(self, x, y)
        self.container.addChild(dummyTileTop.container)
        dummyTileBottom = new DummyTile(self, x, map.dimensions().height + self.border.y + y)
        self.container.addChild(dummyTileBottom.container)

    for y in [0...map.dimensions().width]
      for x in [0...self.border.x]
        dummyTileLeft = new DummyTile(self, x, y + self.border.y)
        self.container.addChild(dummyTileLeft.container)
        dummyTileRight = new DummyTile(self, map.dimensions().width + self.border.x + x, y + self.border.y)
        self.container.addChild(dummyTileRight.container)

    @disableCaching = false
    @cache()
    radio('ew/game/map/loaded').broadcast()

  cache: =>
    return

  screenToMapCoordinates: (screenCoordinates) =>
    x: Math.floor(screenCoordinates.x / MAP_FACTOR.width) - @border.x
    y: Math.floor(screenCoordinates.y / MAP_FACTOR.height) - @border.y

  click: (e) ->
    tile = null
    tile = @tiles[e.tile.y][e.tile.x] if e.tile.x >= 0 and e.tile.y >= 0
    unless tile
      @game.toggleDebug() if e.tile.x is -1 and e.tile.y is -1
      return true
    radio('ew/input/map/clicked').broadcast(tile.tile)
    false