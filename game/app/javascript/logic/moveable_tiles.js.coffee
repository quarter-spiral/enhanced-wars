clone = require('clone')
infinity = 1 / 0

class MoveableTiles
  constructor: (@map, @unit)->
    @initializeMarkers()

    remainingAp = @map.get('game').turnManager.currentPlayer().get('ap')

    while @currentTile and @currentTile.cost <= @unit.get('mp') and @unit.hasEnoughApToMove() and @currentTile.cost isnt infinity
      for tile in @currentTile.tile.neighbors()
        costOfCurrentTile = @costFor(@currentTile.tile)
        if @visitedTiles.indexOf(tile) < 0
          oldCost = @costFor(tile)
          movementCosts = @unit.costToMoveTo(tile)
          newCost = costOfCurrentTile.cost + movementCosts

          @setCostFor(tile, newCost) if oldCost.cost > newCost

      @unvisitedTiles.splice @unvisitedTiles.indexOf(@currentTile.tile), 1
      @visitedTiles.push(@currentTile.tile)

      @currentTile = @getNextTile()

    @unit = unit
    @position = clone unit.position()
    @tiles =  @costs.filter (e) -> e.cost <= unit.get('mp') and e.cost < infinity


  cheapestNeighbor: (mapTile, path) ->
    cheapestCost = null
    for tile in mapTile.neighbors()
      cost = @costFor(tile)
      cheapestCost = cost if cost and (!cheapestCost or (path.indexOf(cost.tile) < 0 and cost.cost < cheapestCost.cost))

    cheapestCost.tile


  directionForMove: (destination, beforeDestination) =>
    lastMove =
      x: destination.position().x - beforeDestination.position().x
      y: destination.position().y - beforeDestination.position().y

    switch lastMove.x
      when 1 # west
        return 'right'
      when -1 # east
        return 'left'
    switch lastMove.y
      when 1 # south
        return 'down'
      when -1 # north
        return 'up'

  pathTo: (mapTile) =>
    return null if @costFor(mapTile) is null

    checkingTile = mapTile
    path = [tile: checkingTile]

    start = @map.tileAt(@unit.position())
    while checkingTile isnt start
      newTile = @cheapestNeighbor(checkingTile, path)
      path[path.length - 1].orientation = @directionForMove(checkingTile, newTile)
      path.push(tile: newTile)
      checkingTile = newTile

    path[path.length - 1].orientation = @directionForMove(path[path.length - 2].tile, path[path.length - 1].tile)

    path.reverse()

  initializeMarkers: =>
    @currentTile = {tile: @map.tileAt(@unit.get('position')), cost: 0}

    @costs = []

    @visitedTiles = [@currentTile.tile]
    @unvisitedTiles = []

    self = @
    @map.eachTile (tile) ->
      cost = {tile: tile}

      if tile is self.currentTile.tile
        cost.cost = 0
      else
        self.unvisitedTiles.push tile
        cost.cost = infinity

      self.costs.push cost

  costFor: (tile) =>
    for cost in @costs
      return cost if cost.tile is tile
    null

  setCostFor: (tile, newCost) =>
    for cost in @costs
      if cost.tile is tile
        cost.cost = newCost
        return

  getNextTile: =>
    nextTile = null
    for tile in @unvisitedTiles
      cost = @costFor(tile)
      nextTile = cost if !nextTile or cost.cost < nextTile.cost
    nextTile

exports 'MoveableTiles', MoveableTiles