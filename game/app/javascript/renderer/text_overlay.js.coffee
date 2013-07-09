needs ['radio'], (radio) ->
  class textOverlay
    constructor: (@parent, @text) ->


      @container =  new CAAT.Foundation.ActorContainer()
      @container.setSize(@parent.width, @parent.height).
          enableEvents(false).
          setGlobalAlpha(true).
          setRotation( 0 )

      @parent.addChild(@container)

      @background = new CAAT.Foundation.ActorContainer().
          setSize(@container.width / 3, @container.height / 3).
          centerAt(@container.width / 2, @container.height / 2)

      @label = new CAAT.TextActor().
          setFont('48px sans-serif').
          setTextFillStyle('#ffffff').
          setTextAlign("center").
          setTextBaseline("middle").
          setText(@text).
          setLocation(@background.width / 2, @background.height / 2)

      @background.addChild(@label)

      @container.addChild(@background)

      scene = CAAT.getCurrentScene()

      rotation = Math.PI/ ( 6 + Math.random() * 40 ) * ((Math.floor(Math.random()*2) * 2 - 1))
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

      @container.addBehavior(fadeOut)
      @container.addBehavior(rotate)
      @container.addBehavior(scale)

  exports textOverlay
