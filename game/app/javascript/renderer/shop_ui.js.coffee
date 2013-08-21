needs ['radio', 'UIElement'], (radio, UIElement) ->
  class UnitButton extends UIElement
    DIMENSIONS =
      width: 100
      height: 100

    FONT_SIZE = 14

    constructor: (@parent, @unitType)->
      super(@parent, null, null)

      @container.setSize(DIMENSIONS.width, DIMENSIONS.height).enableEvents(true)

      @TILE_TYPES = @game.gameRenderer.renderers.unit.TILE_TYPES
      @TILE_SCALE = @game.gameRenderer.renderers.unit.TILE_SCALE
      @unitImage = new CAAT.Foundation.Actor().enableEvents(false)
      @container.addChild(@unitImage)

      @apCostLabel = new CAAT.TextActor().
          setText("#{@game.ruleSet.unitSpecs[@unitType].costs.create} AP").
          setFont("#{FONT_SIZE}px sans-serif").
          setTextFillStyle("#333333").
          setTextBaseline("top").
          setTextAlign("left")
      @container.addChild(@apCostLabel)
      @apCostLabel.centerAt(@container.width / 2, @container.height - FONT_SIZE)

      @container.mouseEnter = (e) =>
        return unless @canBuy()
        @unitImage.setScale(@TILE_SCALE.width * 1.25, @TILE_SCALE.height * 1.25)

      @container.mouseExit = (e) =>
        @unitImage.setScale(@TILE_SCALE.width, @TILE_SCALE.height)

      @container.mouseClick = (e) =>
        @game.turnManager.currentPlayer().buyUnit(@unitType)
        radio('ew/game/shop/close').broadcast()

    canBuy: =>
      @game.turnManager.currentPlayer().canBuy(@unitType)

    setFaction: (@faction) =>
      imageId = "unit/unit/#{@faction}/#{@TILE_TYPES[@unitType][0]}_d.png"
      image = @director.getImage(imageId)
      @unitImage.setBackgroundImage(new CAAT.SpriteImage().initialize(image, 1, 1))
      @unitImage.setScale(@TILE_SCALE.width, @TILE_SCALE.height)
      @unitImage.setLocation(@container.width / 2 - @unitImage.width / 2, -40)

      @unitImage.setAlpha(if @canBuy() then 1 else 0.3)

  class UnitContainer extends UIElement
    DIMENSIONS =
      width: 500
      height: 100

    constructor: ->
      super

      @container.setSize(DIMENSIONS.width, DIMENSIONS.height)
      @container.setLocation(@parent.container.width / 2 - DIMENSIONS.width / 2, 0)
      @container.setFillStyle('#ffffff')
      @container.enableEvents(true)

      buttons = []
      for unitType, data of @game.ruleSet.unitSpecs
        button = new UnitButton(@, unitType)
        button.container.setLocation(button.container.width * buttons.length, 0)
        buttons.push(button)

      radio('ew/game/shop/open').subscribe =>
        button.setFaction(@game.turnManager.currentPlayer().get('faction')) for button in buttons

  class ShopUI extends UIElement
    constructor: ->
      super
      @container.setSize(@parent.container.width, @parent.container.height)
      @container.setLocation(0, 0)

      show = (isShown) =>
        @container.enableEvents(isShown)
        @container.setVisible(isShown)

      show(false)

      radio('ew/game/shop/open').subscribe ->
        show(true)

      radio('ew/game/shop/close').subscribe ->
        show(false)

      @unitContainer = new UnitContainer(@)

      @container.mouseClick = (e) =>
        radio('ew/game/shop/close').broadcast()

  exports 'ShopUI', ShopUI