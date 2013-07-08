merge = require('merge')

exports class FlyingInfo
  defaultOptions =
    fontSize: 22
    color: '#FF0000'

  constructor: (@text, options = {})->
    {@color, @fontSize, @parent} = merge(defaultOptions, options)
    {@x, @y} = @parent

    @container = new CAAT.TextActor().
        setFont("bold #{@fontSize}px sans-serif").
        setText(@text).
        setTextAlign("center").
        setTextFillStyle(@color).
        setTextBaseline("top").
        enableEvents(false).
        setLocation(@x, @y)

    scene = CAAT.getCurrentScene()

    alphaBehaviour = new CAAT.AlphaBehavior().
        setValues(1,0).
        setFrameTime(scene.time+200, 350)

    @.x += @.parent.width / 2

    yMargin = 40 + (Math.random() * 30)
    xMargin = (25 + (Math.random() * 25)) * ((Math.floor(Math.random()*2) * 2 - 1))

    pathBehaviour = new CAAT.PathBehavior().
        setPath(new CAAT.Path().setQuadric(
            @.x, @.y + (Math.random() * 20),
            @.x + xMargin, @.y - yMargin,
            @.x + xMargin, @.y + 80
        )).
        setInterpolator(new CAAT.Interpolator().createExponentialInInterpolator(2, false)).
        setFrameTime(scene.time, 550).
        addListener(
          behaviorExpired: (behavior, time, actor) ->
            actor.setExpired(scene.time)
        )


    @container.addBehavior(pathBehaviour)
    @container.addBehavior(alphaBehaviour)

    @parent.parent.addChild(@container)
