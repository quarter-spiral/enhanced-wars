radio = require('radio')

exports class Renderer
  constructor: (@game, @renderer) ->
    @container = new CAAT.Foundation.ActorContainer()
    @renderer.scene.addChild(@container)
    @container.setLocation(0, 0)
    @container.setSize(@renderer.director.width, @renderer.director.height)

    for asset in @assets
      imageId = asset.replace(/^.*\//, '')
      @renderer.preloader.addElement("#{@id}/#{imageId}", asset)

    self = @
    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      self.ready = true