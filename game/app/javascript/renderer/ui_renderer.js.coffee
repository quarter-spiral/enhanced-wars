radio = require('radio')

exports class UIElement
    constructor: (@parent, @game, @director) ->
      @game ||= @parent.game
      @director ||= @parent.director
      @container =  new CAAT.Foundation.ActorContainer()
      @container.setSize(@parent.container.width, @parent.container.height)
      @container.enableEvents(false)

      @parent.container.addChild(@container)

exports class UIRenderer extends require('Renderer')
  assets: [
    "/assets/ui/undo.png"
    "/assets/ui/end_turn.png"
    "/assets/ui/tik.png"
    "/assets/ui/right_arrow.png"
    "/assets/ui/sign.png"
    "/assets/ui/inspector_card.png"
    "/assets/ui/close_x.png"
    "/assets/ui/fired_icon.png"
    "/assets/ui/moved_icon.png"
  ]

  id: "ui"

  constructor: ->
    super

    BottomUI = require('BottomUI')
    ShopUI = require('ShopUI')
    PointsUI = require('PointsUI')
    WinUI = require('WinUI')
    StreakUI = require('StreakUI')
    InspectorUI = require('InspectorUI')

    TextOverlayQueue = require('TextOverlayQueue')

    originalFindActorAtPosition = @container.findActorAtPosition
    container = @container
    @container.findActorAtPosition = ->
      result = originalFindActorAtPosition.apply(this, arguments)
      if result is container then null else result

    self = @
    radio("ew/renderer/assets-loaded").subscribe ->
      self.bottomUI = new BottomUI(self, self.game, self.gameRenderer.director)
      self.shopUI = new ShopUI(self, self.game, self.gameRenderer.director)
      self.pointsUI = new PointsUI(self, self.game, self.gameRenderer.director)
      self.winUI = new WinUI(self, self.game, self.gameRenderer.director)
      self.streakUI = new StreakUI(self, self.game, self.gameRenderer.director)
      self.textOverlayQueue = new TextOverlayQueue(self)

    radio('ew/input/unit/doubleClicked').subscribe (unit) =>
      self.inspectorUI = new InspectorUI(self,unit)
      

    radio('ew/game/drope-zone-captured').subscribe () =>
      @textOverlayQueue.add("Drop Zone Captured!")

    radio('ew/game/streak').subscribe ({streakValue}) =>
      switch streakValue
        when 0
          label = "First Attack!"
        when 1
          label = "Knock Out!"
        when 2
          label = "Double Down!"
        when 3
          label = "Tripple Threat!"

      @textOverlayQueue.add(label)