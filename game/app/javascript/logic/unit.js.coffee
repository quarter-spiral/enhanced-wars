radio = require('radio')
merge = require('merge')
Module = require('Module')

infinity = 1 / 0

class Unit extends Module
  @include lazy: -> require('EventedObject')
  @include lazy: -> require('ObjectWithPosition')

  defaultOptions =
    selected: false

  dumpableProperties: [
    'position', 'hp', 'faction', 'mp', 'fired', 'orientation', 'type'
  ]

  constructor: (options) ->
    skipReset = options.skipReset
    delete options.skipReset

    @set(merge(defaultOptions, options))

    radio('ew/game/unit/selected').subscribe (selectedUnit) =>
      @attack(selectedUnit) if @get('selected') and @canAttack(selectedUnit) and @hasEnoughApToAttack() and !@get('fired')

      @select(false) if selectedUnit isnt @

    radio('ew/game/map/clicked').subscribe (mapTile) =>
      return unless @get('selected')
      @moveTo(mapTile)

    resetAttributes = =>
      @set(hp: @specs().hp) if @get('hp') is undefined
      @set(mp: @specs().mp, fired: false)
      @select(false)

    radio('ew/game/next-turn').subscribe =>
      resetAttributes()

    resetAttributes() if @game() and @game().ready and !skipReset

  select: (newState) =>
    stateToSet = newState
    oldState = @get('selected')
    itIsMyTurn = @game().turnManager.currentPlayer().get('faction') is @get('faction')
    if newState is undefined
      newState = itIsMyTurn and !@get('selected')

    @set(selected: newState)
    radio('ew/game/unit/selected').broadcast(@) if (newState and !oldState) or (!itIsMyTurn and stateToSet is undefined)
    radio('ew/game/unit/unselected').broadcast(@) if !newState and oldState

  moveTo: (mapTile) =>
    @select(false)

    currentPlayer = @game().turnManager.currentPlayer()
    remainingAp = currentPlayer.get('ap')
    apCost = @distanceTo(mapTile)
    return if remainingAp < apCost

    map = @get('map')
    return unless map.unitCanReach(@, mapTile)

    movementCost = map.costToReach(@, mapTile)
    mp = @get('mp')
    return if movementCost > mp

    path = map.unitsPathTo(@, mapTile)
    newOrientation = path[path.length - 1].orientation

    actionOptions =
      from: @position()
      to: mapTile.position()
      mpCost: movementCost
      apCost: apCost
      oldOrientation: @get('orientation')
      newOrientation: newOrientation
      capturedZones: []
      pointsBefore: @game().dumpPoints()

    for tile in path when dropZone = tile.tile.get('dropZone')
      actionOptions.capturedZones.push(tile: tile.tile.position(), oldFaction: dropZone.get('faction'))
      dropZone.capturedBy(@get('faction'))

    currentPlayer.deductAp(apCost)
    newMp = mp - movementCost

    @set(position: mapTile.position(), mp: newMp, orientation: newOrientation, move: path)
    @select(true) unless newMp <= 1 and @get('fired')

    actionOptions.pointsAfter = @game().dumpPoints()

    MoveAction = require('MoveAction')
    @game().addAction new MoveAction(actionOptions)

  canAttack: (enemy) =>
    return false unless enemy
    return false if enemy.get('faction') is @get('faction')
    return false if @get('fired')

    @distanceTo(enemy) >= @specs().attackRange.min and @distanceTo(enemy) <= @specs().attackRange.max

  attack: (enemy) =>
    return unless @canAttack(enemy)

    Fight = require('Fight')
    fight = new Fight(attacker: @, enemy: enemy)

    @set(fired: true)
    @set(mp: 0) unless @specs().movesAndFires

  die: =>
    @set(hp: 0, dead: true)

  isAlive: =>
    @get('hp') > 0

  canReturnFire: =>
    @specs().returnsFire

  game: =>
    @get('map').get('game')

  tags: =>
    @specs().tags

  isTagged: (tag) =>
    @tags().indexOf(tag) isnt -1

  specs: =>
    @game().ruleSet.unitSpecs[@get('type')]

  costToMoveTo: (tile) =>
    costs = @game().ruleSet.terrainCosts[tile.get('type')]

    unitAtPosition = @get('map').unitAt(tile.position())
    return infinity if unitAtPosition and unitAtPosition.get('faction') isnt @get('faction')

    cost = null
    cost = costs[tag] for tag in @tags() when costs[tag] and (!cost or costs[tag] > cost)
    cost || costs.default

  distanceTo: (enemy) =>
    Math.abs(@position().x - enemy.position().x) + Math.abs(@position().y - enemy.position().y)

  player: =>
    faction = @get('faction')
    @game().players.detect (player) -> player.get('faction') is faction

  hasEnoughApToAttack: =>
    @player().get('ap') >= @specs().costs.fire

exports Unit