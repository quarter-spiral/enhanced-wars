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

    image_id = "unit/unit/#{@unit.faction}/#{TILE_TYPES[@unit.type][@unit.variant || 0]}_#{ORIENTATION_TYPES[@unit.orientation]}.png"
    @image = new CAAT.SpriteImage().initialize(director.getImage(image_id), 1, 1)

    @actor = new CAAT.Foundation.Actor()
    @actor.setBackgroundImage(@image)
    @actor.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height)
    @actor.setScale(TILE_SCALE.width, TILE_SCALE.height)

    @actor.setLocation(
        @unit.position.x * TILE_DIMENSIONS.width * TILE_SCALE.width + (@unit.position.x * TILE_OFFSET.x),
        @unit.position.y * TILE_DIMENSIONS.height * TILE_SCALE.height + (@unit.position.y * TILE_OFFSET.y)
    )

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

    renderer = @
    radio('ew/game/map/load').subscribe ->
      renderer.loadUnits(renderer.game.units)

    radio('ew/renderer/assets-loaded').subscribe (renderer, images) ->
      renderer.loadUnits(renderer.units) if renderer.units

    @container.setParent(@gameRenderer.mapRenderer.container)

  loadUnits: (units) =>
    return @units = units unless @ready

    map = @game.map

    @container.emptyChildren()
    @container.setLocation(TILE_OFFSET.x, TILE_OFFSET.y)
    @container.setSize(
        map.width * TILE_DIMENSIONS.width * TILE_SCALE.width + (map.width * TILE_OFFSET.x),
        map.height * TILE_DIMENSIONS.height * TILE_SCALE.height + (map.height * TILE_OFFSET.y)
    )

    self = @
    for unit in units
      self.container.addChild(new Tile(self, unit).actor)
