needs ['radio'], (radio) ->
  class textOverlay
    constructor: (@parent, @text) ->

      @director = @parent.gameRenderer.director

      @container =  new CAAT.Foundation.ActorContainer()
      @container.setSize(@parent.container.width, @parent.container.height).
          enableEvents(false).
          setGlobalAlpha(true).
          setRotation( 0 )

      @parent.container.addChild(@container)

      @box = new CAAT.Foundation.ActorContainer().
          setSize(500, 148).
          centerAt(@container.width / 2, @container.height / 2)

      @label = new CAAT.TextActor().
          setFont('42px sans-serif').
          setTextFillStyle('#000000').
          setTextAlign("center").
          setTextBaseline("middle").
          setText(@text).
          setLocation(@box.width / 2, @box.height / 2)

      @sign = new CAAT.Foundation.Actor().
          setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/sign.png"), 1, 1))

      @sign.centerAt(Math.floor(@box.width / 2), Math.floor(@box.height / 2))



      @box.addChild(@sign)
      @box.addChild(@label)

      @container.addChild(@box)

      scene = CAAT.getCurrentScene()

      rotation = Math.PI/ ( 20 + Math.random() * 30 ) * ((Math.floor(Math.random()*2) * 2 - 1))
      rotate = new CAAT.RotateBehavior().
            setFrameTime( scene.time, 200 ).
            setValues(0, rotation ).
            setInterpolator(new CAAT.Interpolator().createExponentialOutInterpolator(2, false))

      scale = new CAAT.ScaleBehavior().
            setFrameTime( scene.time, 200 ).
            setValues(6,1,6,1).
            setInterpolator(new CAAT.Interpolator().createExponentialOutInterpolator(2, false))      

      fadeOut = new CAAT.AlphaBehavior().
          setValues(1,0).
          setFrameTime(scene.time+500, 100).
          addListener(
            behaviorExpired: (behavior, time, actor) ->
              actor.setExpired(scene.time)
          )

      if Math.random() > 0.5
        y = 500 * ((Math.floor(Math.random()*2) * 2 - 1))
        x = 0
      else
        x = 500 * ((Math.floor(Math.random()*2) * 2 - 1))
        y = 0

      dropOut = new CAAT.PathBehavior().
        setPath(new CAAT.LinearPath().setInitialPosition(
            0, 0).
          setFinalPosition(
            x, y)).
        setInterpolator(new CAAT.Interpolator().createExponentialInInterpolator(2, false)).
        setFrameTime(scene.time+500, 100).
        addListener(
          behaviorExpired: (behavior, time, actor) ->
            actor.setExpired(scene.time)
        )

      @container.addBehavior(dropOut)
      @container.addBehavior(fadeOut)
      @container.addBehavior(rotate)
      @container.addBehavior(scale)

  exports textOverlay
