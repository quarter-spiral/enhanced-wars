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