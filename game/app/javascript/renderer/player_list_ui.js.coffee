needs ['radio', 'UIElement'], (radio, UIElement) ->

  class PlayerListUI extends UIElement

    constructor: ->
      super

      @container.
            setFillStyle('#fff').
            enableEvents(false).
            setAlpha(0.8)

      @players = new Array
      @vs = new Array
      i = 0;
      width = 10;

      # add player names to the UI (supports unlimited number)

      for player in @game.players

        # add player name to list of names
        @players[i] = new CAAT.TextActor().
            setFont('18px sans-serif').
            setText("Player " + i).
            setTextFillStyle(player.properties.color).
            setTextAlign("left")
        @players[i].
            setLocation(width, 3)
        @container.addChild(@players[i])

        # add current player indicator if applicable
        if player == @game.turnManager.currentPlayer()
          @currentPlayerIndicator = new CAAT.Foundation.Actor().
              setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/playerindicator.png"), 1, 1))
          @container.addChild(@currentPlayerIndicator)
          @currentPlayerIndicator.
              setSize(20, 10).
              setLocation(Math.floor(width +  @players[i].width / 2 - 10), 25)

        width = width + @players[i].width + 10

        # if this is not the last player in the list add "vs"
        if i < @game.players.length-1
          @vs[i] = new CAAT.TextActor().
              setFont('18px sans-serif').
              setText("vs").
              setTextFillStyle('#999999').
              setTextAlign("left")
          @vs[i].
              setLocation(width, 3)
          width = width + @vs[i].width + 10
          @container.addChild(@vs[i])
        i++


      @container.
          setSize(width, 30).
          setLocation(@parent.container.width - width, 5)



  exports PlayerListUI