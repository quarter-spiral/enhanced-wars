radio = require('radio')
clone = require('clone')

class ScrollHandler
  constructor: (@mapRenderer) ->
    radio('ew/input/scrollMap').subscribe @scrollMap
    @reset()

    radio('ew/game/map/loaded').subscribe @reset

  reset: =>
    @minimum =
      x: -1 * (@mapRenderer.container.width - @mapRenderer.parent.width) + @mapRenderer.TILE_OFFSET.x
      y: -1 * (@mapRenderer.container.height - @mapRenderer.parent.height) + @mapRenderer.TILE_OFFSET.y

    @maximum =
      x: @mapRenderer.TILE_OFFSET.x
      y: @mapRenderer.TILE_OFFSET.y

  scrollMap: (diff) =>
    newPosition =
      x: @mapRenderer.container.x - diff.x
      y: @mapRenderer.container.y - diff.y

    newPosition = @toBounds(newPosition)
    @mapRenderer.container.setPosition(newPosition.x, newPosition.y)

  toBounds: (position) =>
    position = clone(position)
    position.x = @minimum.x if position.x < @minimum.x
    position.x = @maximum.x if position.x > @maximum.x

    position.y = @minimum.y if position.y < @minimum.y
    position.y = @maximum.y if position.y > @maximum.y

    position

exports 'ScrollHandler', ScrollHandler