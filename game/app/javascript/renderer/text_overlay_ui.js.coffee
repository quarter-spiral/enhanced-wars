needs ['radio', 'UIElement'], (radio, UIElement) ->
  class textOverlayUI extends UIElement
    constructor: ->
      super

      @container.enableEvents(true)
      @container.setVisible(false)

      @background = new CAAT.Foundation.ActorContainer().
          setSize(@container.width / 3, @container.height / 3).
          centerAt(@container.width / 2, @container.height / 2)

      @text = new CAAT.TextActor().
          setFont('36px sans-serif').
          setTextFillStyle('#ffffff').
          setTextAlign("center").
          setTextBaseline("middle").
          setLocation(@background.width / 2, @background.height / 2)
      @background.addChild(@text)

      @container.addChild(@background)

      radio('ew/game/streak').subscribe ({streak}) =>
        switch streak
          when 0
            @text.setText "First Blood!"
          when 1
            @text.setText "Fist Kill!"
          when 2
            @text.setText "Double Kill!"
          when 3
            @text.setText "Trippe Kill!"

        @background.setFillStyle('#000000').setAlpha(0.6)
        #Show the dialogue with a short delay so it does not obscure the action
        @director.currentScene.createTimer(@container.time, 200, (=>
          #this will happen when the duration is over
          @container.setVisible(true)
        ), (=>
          #this will happen every tick of the game (like very often ;))
        ), (=>
          #this will happen when the timeout is canceled
        ))
        #Hide the dialogue again
        @director.currentScene.createTimer(@container.time, 1000, (=>
          #this will happen when the duration is over
          @container.setVisible(false)
        ), (=>
          #this will happen every tick of the game (like very often ;))
        ), (=>
          #this will happen when the timeout is canceled
        ))


  exports textOverlayUI
