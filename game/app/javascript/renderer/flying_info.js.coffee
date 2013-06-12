merge = require('merge')

behaviors =
  fallingDown: (flyingInfo) ->
    flyingInfo.x += flyingInfo.parent.width / 2

    yMargin = -30 - (Math.random() * 150)
    xMargin = -120 + (Math.random() * 240)

    scene = CAAT.getCurrentScene()

    pathBehaviour = new CAAT.PathBehavior().
        setPath(new CAAT.Path().setQuadric(
            flyingInfo.x, flyingInfo.y,
            flyingInfo.x + xMargin, flyingInfo.y + yMargin,
            flyingInfo.x + xMargin, flyingInfo.y + 500
        )).
        setInterpolator(new CAAT.Interpolator().createExponentialInInterpolator(2, false)).
        setFrameTime(scene.time, 550).
        addListener(
          behaviorExpired: (behavior, time, actor) ->
            actor.setExpired(scene.time)
        )

    pathBehaviour

exports class FlyingInfo
  defaultOptions =
    fontSize: 12
    color: '#FF0000'
    behavior: 'fallingDown'

  constructor: (@text, options = {})->
    {@color, @fontSize, @parent, @behavior} = merge(defaultOptions, options)
    {@x, @y} = @parent

    @container = new CAAT.TextActor().
        setFont("bold #{@fontSize}px sans-serif").
        setText(@text).
        setTextAlign("center").
        setTextFillStyle(@color).
        setTextBaseline("top").
        enableEvents(false).
        setLocation(@x, @y)

    @container.addBehavior(behaviors[@behavior](@))

    @parent.parent.addChild(@container)
