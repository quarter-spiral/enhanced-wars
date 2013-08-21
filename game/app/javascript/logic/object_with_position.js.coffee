class ObjectWithPosition
  position: ->
    {x,y} = @get('position')
    {x,y}

  isAtPosition: (positionToCheck) ->
    {x,y} = @position()
    positionToCheck.x is x and positionToCheck.y is y

exports 'ObjectWithPosition', ObjectWithPosition