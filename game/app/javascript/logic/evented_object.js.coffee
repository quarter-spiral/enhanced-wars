propertiesObj = ->

MicroEvent = require('MicroEvent')
MicroEvent.mixin(propertiesObj)

class EventedObject
    set: (values) ->
      @properties ||= new propertiesObj()

      for key, newValue of values
        oldValue = @properties[key]
        @properties[key] = newValue
        @properties.trigger('change', key, old: oldValue, new: newValue) unless newValue is oldValue

    get: (key) ->
      @properties ||= new propertiesObj()

      @properties[key]

    bindProperty: (boundProperty, fn) ->
      @properties ||= new propertiesObj()
      self = this
      @properties.bind 'change', (changedProperty, values) ->
        return null if changedProperty isnt boundProperty
        fn.apply(self, values)


exports 'EventedObject', EventedObject