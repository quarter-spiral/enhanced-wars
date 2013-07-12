needs ['radio'], (radio) ->
  class InspectorUI
    constructor: (@parent, @unit) ->

      #get current and default unit stats
      hp = @unit.get('hp')
      hpSpecs =  @unit.specs().hp
      mp = @unit.get('mp')
      mpSpecs =  @unit.specs().mp
      canReturnFire = @unit.specs().returnsFire
      faction = @unit.get('faction')
      attackRange =  @unit.specs().attackRange # min and max
      costs =  @unit.specs().costs # fire and create
      bullets =  @unit.specs().bullets
      tags =  @unit.specs().tags
      labels =  @unit.specs().labels


      @director = @parent.gameRenderer.director


      @container =  new CAAT.Foundation.ActorContainer()
      @container.setSize(300, 300).
          centerAt(@parent.container.width / 2, @parent.container.height / 2).
          enableEvents(true).
          setGlobalAlpha(true).
          setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/inspector_card.png"), 1, 1)).
          enableDrag()


      @parent.container.addChild(@container)

      @coseX = new CAAT.Foundation.Actor().
          setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/close_x.png"), 1, 1)).
          enableEvents(false).
          setLocation(265, 20)
      @container.addChild(@coseX)
      

      UNIT_TYPES =
        heavytank: ['ht']
        lighttank: ['lt']
        mediumartillery: ['ma']
        mediumtank: ['mt']
        spiderbot: ['sb']

      image_id = "unit/unit/#{@unit.get('faction')}/#{UNIT_TYPES[@unit.get('type')]}_r.png"
      image = new CAAT.SpriteImage().initialize(@director.getImage(image_id), 1, 1)

      @unitImage = new CAAT.Foundation.Actor().
        setBackgroundImage(image).
        setSize(128, 150).
        setScale(0.5, 0.5).
        setLocation(-10, - 25).
        enableEvents(false)

      @container.addChild(@unitImage)

      @text = new CAAT.TextActor().
          setFont("18px sans-serif").
          setTextAlign("left").
          setTextFillStyle("#666666").
          setTextBaseline("bottom").
          setText(labels.name).
          setLocation(100, 60).
          enableEvents(false)

      @container.addChild(@text)


      statsLine = (text,x,y) =>
        textActor = new CAAT.TextActor().
            setFont("14px sans-serif").
            setTextAlign("left").
            setTextFillStyle("#000000").
            setTextBaseline("bottom").
            setText(text).
            setLocation(x, y).
            enableEvents(false)
        return textActor

      stats = [
        "Health: " + hp + " / " + hpSpecs, 
        "Movement: " + mp + " / " + mpSpecs, 
        "Attack: " + attackRange.min + " - " + attackRange.max
      ]

      if canReturnFire
        stats.push("Can return Fire")

      if @unit.get('fired')
        stats.push("Fired already")

      i = 110
      for line in stats
        @container.addChild(statsLine(line,30,i))
        i = i + 25



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




      @container.addBehavior(rotate)
      @container.addBehavior(scale)

      @container.mouseClick = (e) =>
        remove()

      remove = () =>

        scene = CAAT.getCurrentScene()

        fadeOut = new CAAT.AlphaBehavior().
          setValues(1,0).
          setFrameTime(scene.time, 250).
          addListener(
            behaviorExpired: (behavior, time, actor) ->
              actor.setExpired(scene.time)
          )

        if Math.random() > 0.5
          y = 700 * ((Math.floor(Math.random()*2) * 2 - 1))
          x = 0
        else
          x = 700 * ((Math.floor(Math.random()*2) * 2 - 1))
          y = 0

        dropOut = new CAAT.PathBehavior().
          setPath(new CAAT.LinearPath().setInitialPosition(
              @container.x, @container.y).
            setFinalPosition(
              @container.x + x, @container.y + y)).
          setInterpolator(new CAAT.Interpolator().createExponentialInInterpolator(2, false)).
          setFrameTime(scene.time, 250)

        @container.addBehavior(fadeOut)
        @container.addBehavior(dropOut)


  exports InspectorUI
