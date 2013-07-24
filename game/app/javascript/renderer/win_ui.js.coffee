needs ['radio', 'UIElement'], (radio, UIElement) ->
  class WinUI extends UIElement
    constructor: ->
      super

      @container.enableEvents(true)
      @container.setVisible(false)

      @background = new CAAT.Foundation.ActorContainer().
          setSize(@container.width / 2, @container.height / 2).
          centerAt(@container.width / 2, @container.height / 2)

      @text = new CAAT.TextActor().
          setFont('48px sans-serif').
          setTextFillStyle('#ffffff').
          setTextAlign("center").
          setTextBaseline("middle").
          setLocation(@background.width / 2, @background.height / 2)
      @background.addChild(@text)

      @container.addChild(@background)

      showOrHideWinUi = (player) =>
        setTimeout(=>
          return unless player.won()

          hideAgain = =>
            if player.won()
              setTimeout(hideAgain, 300)
              return
            @container.setVisible(false)

          playerIndex = @game.players.indexOf(player) + 1
          @text.setText "Player #{playerIndex} won!"
          @background.setFillStyle(player.get('color'))
          @container.setVisible(true)
          hideAgain()
        , 50)

      @game.onready =>
        showOrHideWinUi(player) for player in @game.players when player.won()

      radio('ew/game/won').subscribe showOrHideWinUi

  exports WinUI