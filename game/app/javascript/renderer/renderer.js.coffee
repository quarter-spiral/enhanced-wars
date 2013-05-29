exports class Renderer
  constructor: (@game) ->
    createScenes = (director) ->
      scene = director.createScene()
      i = 0

      while i < 30
        w = 30 + (100 * Math.random()) >> 0
        r = (255 * Math.random()) >> 0
        g = (255 * Math.random()) >> 0
        b = (255 * Math.random()) >> 0
        scene.addChild new CAAT.Foundation.Actor().setBounds((director.width * Math.random()) >> 0, (director.height * Math.random()) >> 0, w, w).setFillStyle("rgb(" + r + "," + g + "," + b + ")")
        i++

    CAAT.Module.Initialization.TemplateWithSplash.init(
      # canvas will be 800x600 pixels
      800, 600,

      # and will be added to the end of document. set an id of a canvas or div element
      'game',

      # keep splash at least this 2000 milliseconds
      2000,

      # load these images and set them up for non splash scenes.
      # image elements must be of the form:
      # {id:'<unique string id>',    url:'<url to image>'}
      # No images can be set too.
      [],

      # onEndSplash callback function.
      # Create your scenes on this method.
      createScenes,

      # use this image as splash. It will cover all of director's area. optional.
      "/assets/splash.png",

      # use this image as rotating spinner. optional.
      "/assets/spinner.png"
    )

