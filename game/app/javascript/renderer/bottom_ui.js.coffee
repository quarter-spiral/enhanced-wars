needs ['radio', 'UIElement'], (radio, UIElement) ->
  class APIndicatorDotContainer extends UIElement
    MARGIN = 10

    constructor: ->
      super

      @dots = []
      width = 0
      for i in [1..@game.ruleSet.apPerTurn]
        dot = new APIndicatorDot(@)
        x = (i - 1) * (dot.container.width + MARGIN)
        width = x + dot.container.width
        dot.container.setLocation(x, 0)
        @dots.push dot

      @container.setSize(width, @dots[0].container.height)


    setRemainingActionPoints: (ap) =>
      for i in [1..@game.ruleSet.apPerTurn]
        @dots[i - 1].setAvailable(i > @game.ruleSet.apPerTurn - ap)

  class APIndicatorDot extends UIElement
    COLORS =
      used: '#ffffff'
      available: '#bababa'

    SIZES =
      used: 12
      available: 8

    constructor: ->
      super

      @setAvailable(true)

    setAvailable: (available) ->
      @available = !!available

      size = if @available then SIZES.available else SIZES.used
      center =
        x: @container.x + @container.width / 2
        y: @container.y + @container.height / 2

      @container.setSize(size, size).
          centerAt(center.x, center.y).
          setFillStyle(if @available then COLORS.available else COLORS.used)


  class APText extends UIElement
    FONT_SIZE = 14

    constructor: ->
      super

      @container.setSize(@parent.container.width, @parent.container.height * 0.9)

      @text = new CAAT.TextActor().
          setFont("#{FONT_SIZE}px sans-serif").
          setTextAlign("center").
          setTextFillStyle("#cecece").
          setTextBaseline("bottom")

      @container.addChild(@text)

    setRemainingActionPoints: (ap) ->
      @text.setText("#{@game.ruleSet.apPerTurn - ap}/#{@game.ruleSet.apPerTurn} AP used").
          centerAt(@container.width / 2, @container.height - FONT_SIZE / 2)

  class APIndicator extends UIElement
    constructor: ->
      super

      @container.setBounds(0, 0, @parent.container.width * 0.66, @parent.container.height)
      @container.setFillStyle('#9c9c9c')

      @actionPointsIndicatorDotContainer = new APIndicatorDotContainer(@)
      @actionPointsIndicatorDotContainer.container.centerAt(@container.width / 2, @container.height / 2 - 5)

      @actionPointsText = new APText(@)

    setRemainingActionPoints: (@actionPoints) =>
      @actionPointsIndicatorDotContainer.setRemainingActionPoints(@actionPoints)
      @actionPointsText.setRemainingActionPoints(@actionPoints)


  class RevertTurnControll extends UIElement
    FONT_SIZE = 14

    DIMENSIONS =
      width: 55

    MARGINS =
      bottom: 2
      right: 4

    constructor: ->
      super

      @container.setSize(DIMENSIONS.width, @parent.container.height).
          setFillStyle('#4d4d4d')

      @arrow = new CAAT.Foundation.Actor().
          setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/undo.png"), 1, 1))
      @container.addChild(@arrow)
      @arrow.centerAt(@container.width / 2, @container.height / 2)

      @text = new CAAT.TextActor().
          setFont("#{FONT_SIZE}px sans-serif").
          setTextAlign("right").
          setTextFillStyle("#cecece").
          setTextBaseline("bottom")
      @container.addChild(@text)

      @setRemainingRevertTurnPoints(3)

    setRemainingRevertTurnPoints: (@revertTurnPoints) ->
      @text.setText("#{@revertTurnPoints}").
          setLocation(@container.width - MARGINS.right, @container.height - MARGINS.bottom)


  class EndTurnButton extends UIElement
    FONT_SIZE = 22

    constructor: ->
      super

      @arrow = new CAAT.Foundation.Actor().
          setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/end_turn.png"), 1, 1))
      @container.addChild(@arrow)
      @arrow.setLocation(10, @container.height / 2 - @arrow.height / 2 + 2).
          enableEvents(false)

      @label = new CAAT.TextActor().
          setText("End Turn").
          setFont("#{FONT_SIZE}px sans-serif").
          setTextAlign("left").
          setTextFillStyle("#ffffff").
          setTextBaseline("center").
          enableEvents(false)

      @container.addChild(@label)
      @label.setLocation(@arrow.x + @arrow.width + 5, @container.height / 2 - FONT_SIZE / 2)

      container = @container
      game = @game
      setButtonColor = ->
        container.setFillStyle(game.turnManager.currentPlayer().get('color'))

      setButtonColor()

      radio('ew/game/next-turn').subscribe setButtonColor

      @container.enableEvents(true)
      @container.mouseClick = (e) ->
        game.turnManager.nextTurn()


  exports class BottomUI extends UIElement
    DIMENSIONS = {
      width: 580
      height: 50
    }

    constructor: ->
      super
      @container.setSize(DIMENSIONS.width, DIMENSIONS.height)
      @container.setLocation((@parent.container.width / 2) - (DIMENSIONS.width / 2), @parent.container.height - DIMENSIONS.height)
      @container.setClip(true)
      @container.setGestureEnabled(true)
      @container.enableEvents(true)

      @actionPointsIndicator = new APIndicator(@)

      @revertTurnControll = new RevertTurnControll(@)
      @revertTurnControll.container.setLocation(@actionPointsIndicator.container.width - 1, 0)

      @endTurnButton = new EndTurnButton(@)
      @endTurnButton.container.setBounds(
          @revertTurnControll.container.x + @revertTurnControll.container.width - 1
          0
          @container.width - @revertTurnControll.container.x + @revertTurnControll.container.width
          @container.height
      )

      self = @
      setAp = (ap) ->
        self.actionPointsIndicator.setRemainingActionPoints(ap)

      currentAp = ->
        self.game.turnManager.currentPlayer().get('ap')

      radio('ew/game/next-turn').subscribe ->
        setAp(currentAp())

      @game.onready ->
        setAp(currentAp())
        for player in game.players
          player.bindProperty 'ap', (changedValues) ->
            if self.game.turnManager.currentPlayer() is this
              self.actionPointsIndicator.setRemainingActionPoints(changedValues.ap.new)
