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


      resetPlayerMarker = =>
        @currentPlayerIndicator.setExpired(0) if @currentPlayerIndicator

        # add current player indicator if applicable
        for playerActor in @players
          player = playerActor.player
          if player is @game.turnManager.currentPlayer()
            @currentPlayerIndicator = new CAAT.Foundation.Actor().
                setBackgroundImage(new CAAT.SpriteImage().initialize(@director.getImage("ui/ui/playerindicator.png"), 1, 1))
            @container.addChild(@currentPlayerIndicator)
            @currentPlayerIndicator.
                setSize(20, 10).
                setLocation(playerActor.x + playerActor.width / 2 - 10, 25)

      radio('ew/game/next-turn').subscribe(resetPlayerMarker)


      radio('ew/game/map/load').subscribe =>
        i = 0
        width = 10

        player.setExpired(0) for player in @players
        @players.splice(0, @players.length)
        vs.setExpired(0) for vs in @vs
        @vs.splice(0, @vs.length)

        # add player names to the UI (supports unlimited number)
        for player in @game.players
          playerName = '?'
          if window.player and window.player.uuid is player.get('uuid')
            playerName  = "you"
          if game.match.players[player.get('uuid')]
            playerName = game.match.players[player.get('uuid')].name
          # add player name to list of names
          @players[i] = new CAAT.TextActor().
              setFont('18px sans-serif').
              setText(playerName).
              setTextFillStyle(player.properties.color).
              setTextAlign("left")
          @players[i].
              setLocation(width, 3)
          @players[i].player = player
          @container.addChild(@players[i])

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

        resetPlayerMarker()

        @container.
            setSize(width, 30).
            setLocation(@parent.container.width - width, 5)

  exports PlayerListUI