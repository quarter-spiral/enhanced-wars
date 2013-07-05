merge = require('merge')

behaviors =
  fallingDown: (flyingInfo) ->
    flyingInfo.x += flyingInfo.parent.width / 2

    yMargin = 50 + (Math.random() * 30)
    xMargin = (25 + (Math.random() * 25)) * ((Math.floor(Math.random()*2) * 2 - 1))

    scene = CAAT.getCurrentScene()

    pathBehaviour = new CAAT.PathBehavior().
        setPath(new CAAT.Path().setQuadric(
            flyingInfo.x, flyingInfo.y + (Math.random() * 20),
            flyingInfo.x + xMargin, flyingInfo.y - yMargin,
            flyingInfo.x + xMargin, flyingInfo.y + 60
        )).
        setInterpolator(new CAAT.Interpolator().createExponentialInInterpolator(2, false)).
        setFrameTime(scene.time, 500).
        addListener(
          behaviorExpired: (behavior, time, actor) ->
            actor.setExpired(scene.time)
        )

    pathBehaviour

  fadingOut: (flyingInfo) ->

    scene = CAAT.getCurrentScene()

    alphaBehaviour = new CAAT.AlphaBehavior().
        setValues(1,0).
        setFrameTime(scene.time+150, 480).
        addListener(
          behaviorExpired: (behavior, time, actor) ->
            actor.setExpired(scene.time)
        )

    alphaBehaviour

exports class FlyingInfo
  defaultOptions =
    fontSize: 22
    color: '#FF0000'
    behaviora: 'fallingDown'
    behaviorb: 'fadingOut'

  constructor: (@text, options = {})->
    {@color, @fontSize, @parent, @behaviora, @behaviorb} = merge(defaultOptions, options)
    {@x, @y} = @parent

    @container = new CAAT.TextActor().
        setFont("bold #{@fontSize}px sans-serif").
        setText(@text).
        setTextAlign("center").
        setTextFillStyle(@color).
        setTextBaseline("top").
        enableEvents(false).
        setLocation(@x, @y)

    @container.addBehavior(behaviors[@behaviora](@))
    @container.addBehavior(behaviors[@behaviorb](@))

    @parent.parent.addChild(@container)
