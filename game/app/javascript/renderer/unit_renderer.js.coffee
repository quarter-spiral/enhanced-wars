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
  y: -16
}

OVERALL_OFFSET = {
  x: 0
  y: 10
}

MAP_FACTOR =
  width: (TILE_DIMENSIONS.width * TILE_SCALE.width + TILE_OFFSET.x) - 2
  height: (TILE_DIMENSIONS.height * TILE_SCALE.height + TILE_OFFSET.y) - 1

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

    unitActor = new CAAT.Foundation.Actor()

    setImage = (orientation) =>
      orientation ||= @unit.get('orientation')
      image_id = "unit/unit/#{@unit.get('faction')}/#{TILE_TYPES[@unit.get('type')][@unit.get('variant') || 0]}_#{ORIENTATION_TYPES[@unit.get('orientation')]}.png"
      @image = new CAAT.SpriteImage().initialize(director.getImage(image_id), 1, 1)
      unitActor.setBackgroundImage(@image)

    setImage()

    @actor = new CAAT.Foundation.ActorContainer()
    @actor.setSize(
        TILE_DIMENSIONS.width * TILE_SCALE.width
        TILE_DIMENSIONS.height * TILE_SCALE.height
    )

    @hpMeterContainer = new CAAT.Foundation.ActorContainer().
        setFillStyle('#FFFFFF').
        setSize(@actor.width - 30, 4).
        setAlpha(0.8)

    @hpMeter = new CAAT.Foundation.Actor().
        setFillStyle(@unit.player().get('color')).
        setSize(@hpMeterContainer.width, @hpMeterContainer.height).
        setLocation(0, 0)
    @hpMeterContainer.addChild(@hpMeter)

    toMapCoordinates = (position) =>
      {x,y} = position

      border = @renderer.mapRenderer.border

      x: (x + border.x) * MAP_FACTOR.width + OVERALL_OFFSET.x
      y: (y + border.y) * MAP_FACTOR.height + OVERALL_OFFSET.y

    pathBehaviour = null

    relocateUnit = =>
      {x,y} = toMapCoordinates(@unit.position())

      unless pathBehaviour
        pathBehaviour = new CAAT.PathBehavior().
            setPath(new CAAT.Path().setLinear(x,y, x,y)).
            setInterpolator(new CAAT.Interpolator().createExponentialInOutInterpolator(2,false)).
            setFrameTime(@actor.time, 10)
        @actor.addBehavior(pathBehaviour)

      @actor.setLocation(x, y)

    relocateUnit()

    transitionUnit = (mapPath) =>
      {x,y} = toMapCoordinates(mapPath[0].tile.position())
      path = new CAAT.Path().beginPath(x, y)
      for segment in mapPath when segment isnt mapPath[0]
        {x,y} = toMapCoordinates(segment.tile.position())
        path.addLineTo(x, y)
      path.endPath()

      timePerTile = 15000 / Math.pow(@renderer.game.ruleSet.unitSpecs[@unit.get('type')].mp, 2)
      pathStartTime = @actor.time
      pathDuration = timePerTile * (mapPath.length - 1)
      pathBehaviour.
          setPath(path).
          setFrameTime(pathStartTime, pathDuration)

      orientations = mapPath[1..-1].map (e) -> e.orientation
      for startTime in pathBehaviour.path.pathSegmentStartTime
        director.currentScene.createTimer(pathStartTime, startTime * pathDuration, ->
          setImage(orientations.shift())
        )

    @actor.tile = @

    unitActor.setBackgroundImage(@image)
    unitActor.setSize(TILE_DIMENSIONS.width, TILE_DIMENSIONS.height)
    unitActor.scaleTX = 0
    unitActor.scaleTY = 0
    unitActor.setScale(TILE_SCALE.width, TILE_SCALE.height)

    @actor.addChild(unitActor)

    @actor.addChild(@hpMeterContainer)
    @hpMeterContainer.setLocation(@actor.width / 2 - @hpMeterContainer.width / 2, @actor.height - @hpMeterContainer.height - 5)

    unit.bindProperty 'selected', (changedValues) =>
      unitActor.setAlpha(if @unit.get('selected') then 0.5 else 1)

    unit.bindProperty 'position', (changedValues) =>
      relocateUnit() unless changedValues.move

    unit.bindProperty 'move', (changedValues) =>
      transitionUnit(changedValues.move.new)

    unit.bindProperty 'hp', (changedValues) =>
      percentage = @unit.get('hp') * 1.0 / @unit.specs().hp
      newWidth = (@hpMeterContainer.width - 2) * percentage
      @hpMeter.setSize(newWidth, @hpMeter.height)

    unit.fireProperty('hp')

    FlyingInfoQueue = require('FlyingInfoQueue')
    @infoQueue = new FlyingInfoQueue(parent: @actor)
    radio('ew/game/attack').subscribe ({attacker, enemy, bullet}) =>
      return unless enemy is @unit

      if bullet.hit
        @infoQueue.add("-#{bullet.damage}")
        # @infoQueue.add("Hit")
        @infoQueue.add("Critical!") if bullet.criticalStrike
      else
        @infoQueue.add("Miss")

  remove: =>
    @actor.setDiscardable(true)
    @actor.setExpired(true)

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

    @mapRenderer = @gameRenderer.renderers.map

    MAP_TILE_OFFSET = @mapRenderer.TILE_OFFSET

    renderer = @
    radio('ew/game/map/load').subscribe ->
      renderer.loadUnits(renderer.game.units)

    radio('ew/renderer/assets-loaded').subscribe (renderer, images) ->
      renderer.loadUnits(renderer.units) if renderer.units

    radio('ew/game/unit/added-to-player').subscribe (unit) =>
      @loadUnit(unit)

    @container.setParent(@gameRenderer.renderers.map.container)

    @TILE_TYPES = TILE_TYPES
    @TILE_SCALE = TILE_SCALE

  loadUnits: (units) =>
    @units = units
    return unless @ready

    map = @game.map

    @container.emptyChildren()
    @container.setLocation(MAP_TILE_OFFSET.x, MAP_TILE_OFFSET.y)

    border = @mapRenderer.border
    @container.setSize(
        (map.dimensions().width + (border.x * 2)) * MAP_FACTOR.width
        (map.dimensions().height + (border.y * 2)) * MAP_FACTOR.height
    )

    @tiles = []

    @loadUnit(unit) for unit in units

  loadUnit: (unit) =>
    tile = new Tile(@, unit)
    @container.addChild(tile.actor)
    @tiles.push(tile)
    @units.push(unit)

    self = @
    unit.bindProperty 'dead', (changedValues) ->
      self.removeUnit(this) unless this.isAlive()

  click: (e) =>
    for unit in @units
      if unit.isAtPosition(e.tile)
        radio('ew/input/unit/clicked').broadcast(unit)
        return false
    true

  doubleClick: (e) =>
    for unit in @units
      if unit.isAtPosition(e.tile)
        radio('ew/input/unit/doubleClicked').broadcast(unit)
        return false
    true

  removeUnit: (unit) =>
    @units = @units.filter (u) -> u.isAlive()
    for tile in @tiles
      return tile.remove() if tile.unit is unit