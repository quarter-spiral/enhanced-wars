needs ['radio', 'UIElement'], (radio, UIElement) ->
  class textOverlayUI extends UIElement
    constructor: ->
      super

      @container.enableEvents(true)
      @container.setVisible(false)

      @background = new CAAT.Foundation.ActorContainer().
          setSize(@container.width / 3, @container.height / 3).
          centerAt(@container.width / 2, @container.height / 2).
          setFillStyle('#000000').setAlpha(0.6)

      @text = new CAAT.TextActor().
          setFont('36px sans-serif').
          setTextFillStyle('#ffffff').
          setTextAlign("center").
          setTextBaseline("middle").
          setLocation(@background.width / 2, @background.height / 2)
      @background.addChild(@text)

      @container.addChild(@background)

      radio('ew/game/drope-zone-captured').subscribe () =>

        @text.setText "Drop Zone Captured!"

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

      radio('ew/game/streak').subscribe ({streakValue}) =>
        switch streakValue
          when 0
            @text.setText "Attack!"
          when 1
            @text.setText "Knock Out!"
          when 2
            @text.setText "Double Down!"
          when 3
            @text.setText "Tripple Threat!"
          
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