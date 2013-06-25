needs ['radio', 'UIElement'], (radio, UIElement) ->
  class TopHint extends UIElement
    DIMENSIONS =
      height: 40

    constructor: ->
      super
      @container.setSize(@parent.container.width, DIMENSIONS.height).
          setLocation(0, 0).
          setFillStyle('#9c9c9c').
          enableEvents(false)

      @pointsLabel = new CAAT.TextActor().
          setFont('20px sans-serif').
          setText(@game.ruleSet.pointsForWin).
          setTextFillStyle('#ffffff').
          setTextAlign("center")

      @container.addChild(@pointsLabel)
      @pointsLabel.centerAt(@container.width / 2, @pointsLabel.height / 1.8)

      @subtitleLabel = new CAAT.TextActor().
          setFont('10px sans-serif').
          setText("WINS").
          setTextFillStyle('#ffffff').
          setTextAlign("center")
      @container.addChild(@subtitleLabel)
      @subtitleLabel.centerAt(@container.width / 2, @pointsLabel.height + @subtitleLabel.height / 1.5 - 2)

  class PointBarContainer extends UIElement
    constructor: ->
      super

      i = 0
      bars = []

      for player in @game.players
        bar = new PointBar(@, player)
        bar.container.setLocation(i * (1 - bar.widthFactor) * @container.width, @container.height)
        bars.push bar: bar, player: player
        i++


      radio('ew/game/next-turn').subscribe =>
        currentPlayer = @game.turnManager.currentPlayer()

        i = 0
        for bar in bars
          @container.setZOrder(bar.bar.container, if bar.player is currentPlayer then i else (bars.length * -1 + i))           
          i++


      radio('ew/game/pointsScored').subscribe =>
        maxScore = -1
        maxScorePlayer = null
        for bar in bars
          if bar.player.get('points') > maxScore
            maxScore = bar.player.get('points')
            maxScorePlayer = bar.player            
          bar.bar.label.container.setLocation(bar.bar.label.container.x,0)
          bar.bar.label.line.setLocation(0,0)

        for bar in bars
          if bar.player is maxScorePlayer
            bar.bar.label.container.setLocation(bar.bar.label.container.x,-1 * bar.bar.label.container.height)
            bar.bar.label.line.setLocation(0,bar.bar.label.container.height)



  class PointBarLabel extends UIElement
    DIMENSIONS =
      width: 35
      height: 30

    MARGIN =
      x: -5

    LINE =
      width: 1

    constructor: ->
      super

      @container.setFillStyle(@parent.container.fillStyle).
        setSize(DIMENSIONS.width, DIMENSIONS.height).
        setLocation(@parent.container.x - DIMENSIONS.width + MARGIN.x, -1 * DIMENSIONS.height)

      @label = new CAAT.TextActor().
          setFont('20px sans-serif').
          setText(@game.ruleSet.pointsForWin).
          setTextFillStyle('#ffffff').
          setTextAlign("center")
      @label.setSize(@container.width, @label.height)

      @container.addChild(@label)
      @label.setLocation(@container.width / 2, @container.height / 2 - @label.height / 2)

      @line = new CAAT.Foundation.Actor().
          setSize(@container.width + MARGIN.x * -1, LINE.width).
          setFillStyle(@container.fillStyle)
      @container.addChild(@line)
      @line.setLocation(0, @container.height)

      @parent.player.bindProperty 'points', (changedValues) =>
        @label.setText(changedValues.points.new)


  class PointBar extends UIElement
    constructor: (@parent, @player) ->
      super(@parent)

      @widthFactor = 2.0 / (@game.players.length + 1)

      @container.setFillStyle(@player.get('color')).
          setSize(@parent.container.width * @widthFactor)


      @label = new PointBarLabel(@)

      @player.bindProperty 'points', @adoptSize


    adoptSize: =>
      @container.setSize(@container.width, @parent.container.height * (@player.get('points') * 1.0 / @game.ruleSet.pointsForWin)).
          setLocation(@container.x, @parent.container.height - @container.height)


  class PointsUI extends UIElement
    DIMENSIONS =
      width: 35
      height: 480

    constructor: ->
      super

      @container.setSize(DIMENSIONS.width, DIMENSIONS.height).
            setLocation(@parent.container.width - DIMENSIONS.width, @parent.container.height / 2 - DIMENSIONS.height / 2).
            setFillStyle('#353535').
            enableEvents(false)

      @topHint = new TopHint(@)

      barContainer = new PointBarContainer(@)
      barContainer.container.
          setSize(@container.width, @container.height - @topHint.container.height).
          setLocation(0, @topHint.container.height)

  exports PointsUI