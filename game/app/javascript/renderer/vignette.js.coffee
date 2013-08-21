needs [], () ->
  class Vignette

    constructor: (@parent, @game) ->

      @director = @parent.gameRenderer.director

      @container =  new CAAT.Foundation.ActorContainer()
          .setSize(@parent.container.width, @parent.container.height)
          .setLocation(0,0)
          .enableEvents(false)
          #.setFillStyle('#9c9c9c')

      @parent.container.addChild(@container)


      gradientImage = new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/gradient.png"), 1,1 )

      @bottomGradient = new CAAT.Foundation.Actor()
          .setSize(@container.width, 80)
          .setLocation(0,@container.height-80)
          .setBackgroundImage(gradientImage.getRef(), false)
          .setImageTransformation(CAAT.Foundation.SpriteImage.TR_TILE)
      @container.addChild(@bottomGradient)

      @topGradient = new CAAT.Foundation.Actor()
          .setSize(@container.width, 80)
          .setBackgroundImage(gradientImage.getRef(), false)
          .setImageTransformation(CAAT.Foundation.SpriteImage.TR_TILE)
          .setRotation( Math.PI )
          .setLocation(0,0)
      @container.addChild(@topGradient)

  exports "Vignette", Vignette