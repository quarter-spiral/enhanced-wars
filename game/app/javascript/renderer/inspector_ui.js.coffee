needs ['radio'], (radio) ->
  class InspectorUI
    constructor: (@parent, @unit) ->

      #get current and default unit stats
      hp = @unit.get('hp')
      hpSpecs =  @unit.specs().hp
      mp = @unit.get('mp')
      mpSpecs =  @unit.specs().mp
      fired = @unit.fired
      canReturnFire = @unit.specs().returnsFire
      faction = @unit.get('faction')
      attackRange =  @unit.specs().attackRange # min and max
      costs =  @unit.specs().costs # fire and create
      bullets =  @unit.specs().bullets
      tags =  @unit.specs().tags


      @director = @parent.gameRenderer.director

      @container =  new CAAT.Foundation.ActorContainer()
      @container.setSize(300, 400).
          centerAt(@parent.container.width / 2, @parent.container.height / 2).
          enableEvents(true).
          enableDrag()


      @parent.container.addChild(@container)

      @box = new CAAT.Foundation.ActorContainer().
          setSize(@container.width, @container.height).
          centerAt(@container.width / 2, @container.height / 2).
          setFillStyle('#ffffff').
          enableEvents(false)

      @container.addChild(@box)

      scene = CAAT.getCurrentScene()

      rotation = Math.PI/ ( 50 + Math.random() * 300 ) * ((Math.floor(Math.random()*2) * 2 - 1))
      rotate = new CAAT.RotateBehavior().
            setFrameTime( scene.time, 200 ).
            setValues(0, rotation ).
            setInterpolator(new CAAT.Interpolator().createExponentialOutInterpolator(2, false))

      scale = new CAAT.ScaleBehavior().
            setFrameTime( scene.time, 200 ).
            setValues(6,1,6,1).
            setInterpolator(new CAAT.Interpolator().createExponentialOutInterpolator(2, false))




      @box.addBehavior(rotate)
      @box.addBehavior(scale)

      @container.mouseClick = (e) =>
        remove()

      remove = () =>

        scene = CAAT.getCurrentScene()

        fadeOut = new CAAT.AlphaBehavior().
          setValues(1,0).
          setFrameTime(scene.time, 150).
          addListener(
            behaviorExpired: (behavior, time, actor) ->
              actor.parent.setExpired(scene.time)
          )

        if Math.random() > 0.5
          y = 500 * ((Math.floor(Math.random()*2) * 2 - 1))
          x = 0
        else
          x = 500 * ((Math.floor(Math.random()*2) * 2 - 1))
          y = 0

        dropOut = new CAAT.PathBehavior().
          setPath(new CAAT.LinearPath().setInitialPosition(
              @box.x, @box.y).
            setFinalPosition(
              @box.x + x, @box.y + y)).
          setInterpolator(new CAAT.Interpolator().createExponentialInInterpolator(2, false)).
          setFrameTime(scene.time, 150)

        @box.addBehavior(fadeOut)
        @box.addBehavior(dropOut)


  exports InspectorUI
