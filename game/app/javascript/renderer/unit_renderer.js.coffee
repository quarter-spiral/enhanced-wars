radio = require('radio')
clone = require('clone')

TILE_DIMENSIONS =
  width:  128
  height: 150

TILE_SCALE = {
  width: 0.5
  height: 0.5
}

MAP_TILE_OFFSET = null

TILE_OFFSET = {
  x: 0
  y: 10
}

TILE_TYPES =
  heavytank: ['ht']
  lighttank: ['lt']
  mediumartillery: ['ma']
  mediumtank: ['mt']
  spiderbot: ['sb']

ORIENTATION_TYPES =
  right: 'r'
  left:  'l'
  up:    'u'
  down:  'd'

class Tile
  constructor: (@renderer, @unit) ->

    director = @renderer.gameRenderer.director

    image_id = "unit/unit/#{@unit.get('faction')}/#{TILE_TYPES[@unit.get('type')][@unit.get('variant') || 0]}_#{ORIENTATION_TYPES[@unit.get('orientation')]}.png"
    @image = new CAAT.SpriteImage().initialize(director.getImage(image_id), 1, 1)

    @actor = new CAAT.Foundation.ActorContainer()
    @actor.setSize(
        TILE_DIMENSIONS.width * TILE_SCALE.width
        TILE_DIMENSIONS.height * TILE_SCALE.height
    )

    relocateUnit = =>
      {x,y} = @unit.position()
      @actor.setLocation(
        x * TILE_DIMENSIONS.width * TILE_SCALE.width + (y * MAP_TILE_OFFSET.x) + TILE_OFFSET.x
        y * TILE_DIMENSIONS.height * TILE_SCALE.height + (y * MAP_TILE_OFFSET.y) + TILE_OFFSET.y
      )
    relocateUnit()

    @actor.tile = @

    unitActor = new CAAT.Foundation.Actor()
    unitActor.setBackgroundImage(@image)
    unitActor.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height)
    unitActor.scaleTX = 0
    unitActor.scaleTY = 0
    unitActor.setScale(TILE_SCALE.width, TILE_SCALE.height)

    @actor.addChild(unitActor)

    unit.bindProperty 'selected', (changedValues) =>
      unitActor.setAlpha(if @unit.get('selected') then 0.1 else 1)

    unit.bindProperty 'position', (changedValues) =>
      relocateUnit()

exports class UnitRenderer extends require('Renderer')
  assets: [
    '/assets/unit/0/ht_d.png'
    '/assets/unit/0/ht_l.png'
    '/assets/unit/0/ht_r.png'
    '/assets/unit/0/ht_u.png'
    '/assets/unit/0/lt_d.png'
    '/assets/unit/0/lt_l.png'
    '/assets/unit/0/lt_r.png'
    '/assets/unit/0/lt_u.png'
    '/assets/unit/0/ma_d.png'
    '/assets/unit/0/ma_l.png'
    '/assets/unit/0/ma_r.png'
    '/assets/unit/0/ma_u.png'
    '/assets/unit/0/mt_d.png'
    '/assets/unit/0/mt_l.png'
    '/assets/unit/0/mt_r.png'
    '/assets/unit/0/mt_u.png'
    '/assets/unit/0/sb_d.png'
    '/assets/unit/0/sb_l.png'
    '/assets/unit/0/sb_r.png'
    '/assets/unit/0/sb_u.png'
    '/assets/unit/1/ht_d.png'
    '/assets/unit/1/ht_l.png'
    '/assets/unit/1/ht_r.png'
    '/assets/unit/1/ht_u.png'
    '/assets/unit/1/lt_d.png'
    '/assets/unit/1/lt_l.png'
    '/assets/unit/1/lt_r.png'
    '/assets/unit/1/lt_u.png'
    '/assets/unit/1/ma_d.png'
    '/assets/unit/1/ma_l.png'
    '/assets/unit/1/ma_r.png'
    '/assets/unit/1/ma_u.png'
    '/assets/unit/1/mt_d.png'
    '/assets/unit/1/mt_l.png'
    '/assets/unit/1/mt_r.png'
    '/assets/unit/1/mt_u.png'
    '/assets/unit/1/sb_d.png'
    '/assets/unit/1/sb_l.png'
    '/assets/unit/1/sb_r.png'
    '/assets/unit/1/sb_u.png'
  ]

  id: "unit"

  constructor: ->
    super

    MAP_TILE_OFFSET = @gameRenderer.renderers.map.TILE_OFFSET

    renderer = @
    radio('ew/game/map/load').subscribe ->
      renderer.loadUnits(renderer.game.units)

    radio('ew/renderer/assets-loaded').subscribe (renderer, images) ->
      renderer.loadUnits(renderer.units) if renderer.units

    @container.setParent(@gameRenderer.renderers.map.container)

  loadUnits: (units) =>
    @units = units
    return unless @ready

    map = @game.map

    @container.emptyChildren()
    @container.setLocation(MAP_TILE_OFFSET.x, MAP_TILE_OFFSET.y)
    @container.setSize(
        map.dimensions().width * TILE_DIMENSIONS.width * TILE_SCALE.width + (map.dimensions().width * MAP_TILE_OFFSET.x),
        map.dimensions().height * TILE_DIMENSIONS.height * TILE_SCALE.height + (map.dimensions().height * MAP_TILE_OFFSET.y)
    )

    self = @
    for unit in units
      tile = new Tile(self, unit)
      self.container.addChild(tile.actor)


  click: (e) =>
    for unit in @units
      if unit.isAtPosition(e.tile)
        radio('ew/input/unit/clicked').broadcast(unit)
        return false
    true
