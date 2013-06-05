radio = require('radio')

exports class Renderer
  constructor: (@game, @gameRenderer, @parent) ->
    @parent ||= @gameRenderer.scene
    @container = new CAAT.Foundation.ActorContainer()
    @parent.addChild(@container)
    @container.setLocation(0, 0)
    @container.setSize(@gameRenderer.director.width, @gameRenderer.director.height)
    @container.setGestureEnabled(true)
    @container.enableEvents(true)

    for asset in @assets
      imageId = asset.replace(/\/assets\//, '')
      @gameRenderer.preloader.addElement("#{@id}/#{imageId}", asset)

    self = @
    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      self.ready = true