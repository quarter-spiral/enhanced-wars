needs ['radio', 'UIElement'], (radio, UIElement) ->
  class StreakLabel extends UIElement
    DIMENSIONS =
      width: 105
      height: 45

    FONT_SIZE =
      label: 14
      points: 12

    constructor: (@parent, @text, @points, showArrow = true) ->
      super(@parent)

      @container.setSize(DIMENSIONS.width, DIMENSIONS.height)

      if showArrow
        @arrow = new CAAT.Foundation.Actor().
            setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/right_arrow.png"), 1, 1)).
            setAlpha(0.5)

        @arrow.centerAt(@container.width + @arrow.width / 2, @container.height / 2)
        @container.addChild(@arrow)

      @tik = new CAAT.Foundation.Actor().
          setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/tik.png"), 1, 1)).
          centerAt(@container.width / 2, @container.height / 2).
          setVisible(false)
      @container.addChild(@tik)

      @label = new CAAT.TextActor().
          setText(@text).
          setFont("#{FONT_SIZE.label}px sans-serif").
          setTextAlign("center").
          setTextFillStyle("#ffffff").
          setTextBaseline("middle").
          setAlpha(0.5).
          centerAt(@container.width / 2, @container.height / 2)
      @container.addChild(@label)

      pointsText = if @points is 1 then "Point" else "Points"
      @pointsLabel = new CAAT.TextActor().
          setText("+#{@points} #{pointsText}").
          setFont("#{FONT_SIZE.points}px sans-serif").
          setTextAlign("center").
          setTextFillStyle("#ffffff").
          setTextBaseline("middle").
          setAlpha(0.5).
          centerAt(@container.width / 2, 0)
      @pointsLabel.setLocation(@pointsLabel.x, @container.height)
      @container.addChild(@pointsLabel)


    activate: =>
      @label.setVisible(false)
      @tik.setVisible(true)
      @pointsLabel.setAlpha(1)
      @arrow.setAlpha(1) if @arrow

    deactivate: =>
      @tik.setVisible(false)
      @label.setVisible(true)
      @pointsLabel.setAlpha(0.5)
      @arrow.setAlpha(0.5) if @arrow

  class StreakUI extends UIElement
    DIMENSIONS =
      width: 480
      height: 45

    EXPANDED_DIMENSIONS =
      width: 480
      height: 65

    LABEL_MARGIN =
      x: 15

    constructor: ->
      super

      @container.enableEvents(true).
          setVisible(false).
          setFillStyle('#575757').
          setClip(true).
          setSize(DIMENSIONS.width, DIMENSIONS.height).
          centerAt(@parent.container.width / 2, DIMENSIONS.height / 2)

      @aggressionLabel = new StreakLabel(@, "Aggression", 1)

      @knockOutLabel = new StreakLabel(@, "Knock Out", 1)
      @knockOutLabel.container.setLocation(@aggressionLabel.container.width + @aggressionLabel.arrow.width, 0)

      @doubleDownLabel = new StreakLabel(@, "Double Down", 3)
      @doubleDownLabel.container.setLocation(@knockOutLabel.container.x + @knockOutLabel.container.width + @knockOutLabel.arrow.width, 0)

      @tripleThreatLabel = new StreakLabel(@, "Triple Threat", 5, false)
      @tripleThreatLabel.container.setLocation(@doubleDownLabel.container.x + @doubleDownLabel.container.width + @doubleDownLabel.arrow.width, 0)

      self = @
      @game.onready =>
        for player in @game.players
          player.bindProperty 'fired', (changedValues) ->
            if this is self.game.turnManager.currentPlayer()
              self.container.setVisible(true)
              self.aggressionLabel.activate()

          player.bindProperty 'streak', (changedValues) ->
            if this is self.game.turnManager.currentPlayer()
              switch changedValues.streak.new
                when 0
                  # nothing
                  false
                when 1
                  self.knockOutLabel.activate()
                when 2
                  self.knockOutLabel.activate()
                  self.doubleDownLabel.activate()
                else
                  self.knockOutLabel.activate()
                  self.doubleDownLabel.activate()
                  self.tripleThreatLabel.activate()

      radio('ew/game/next-turn').subscribe =>
        @aggressionLabel.deactivate()
        @knockOutLabel.deactivate()
        @doubleDownLabel.deactivate()
        @tripleThreatLabel.deactivate()
        @container.setVisible(false)

      @container.mouseEnter = =>
        @container.setSize(EXPANDED_DIMENSIONS.width, EXPANDED_DIMENSIONS.height).
            centerAt(@parent.container.width / 2, EXPANDED_DIMENSIONS.height / 2)

      @container.mouseExit = =>
        @container.setSize(DIMENSIONS.width, DIMENSIONS.height).
            centerAt(@parent.container.width / 2, DIMENSIONS.height / 2)

      radio('ew/game/shop/open').subscribe =>
        @container.setVisible(false)

      radio('ew/game/shop/close').subscribe =>
        @container.setVisible(true)

  exports StreakUI
