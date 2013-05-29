radio = require('radio')

exports class Renderer
  actors: new CAAT.ActorContainer()

  constructor: (@game, @renderer) ->
    @actors = new CAAT.Foundation.ActorContainer().setBounds(0, 0, @renderer.director.width, @renderer.director.height);
    @renderer.scene.addChild(@actors)

    for asset in @assets
      imageId = asset.replace(/^.*\//, '')
      @renderer.preloader.addElement("#{@id}/#{imageId}", asset)

    self = @
    radio("ew/renderer/assets-loaded").subscribe (renderer, images) ->
      self.ready = true