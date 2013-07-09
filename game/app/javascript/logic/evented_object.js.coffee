propertiesObj = ->

typeIsArray = require('typeIsArray')
MicroEvent = require('MicroEvent')
MicroEvent.mixin(propertiesObj)

class EventedObject
    set: (values) ->
      @properties ||= new propertiesObj()

      changes = {}
      for key, newValue of values
        oldValue = @properties[key]
        @properties[key] = newValue
        changes[key] = {old: oldValue, new: newValue} unless newValue is oldValue

      @properties.trigger('change', changes)

    get: (key) ->
      @properties ||= new propertiesObj()

      @properties[key]

    dump: ->
      if @dumpableProperties is undefined
        require('clone')(@properties)
      else
        result = {}
        result[property] = @.get(property) for property in @dumpableProperties
        result

    bindProperty: (boundProperties, fn) ->
      boundProperties = [boundProperties] unless typeIsArray(boundProperties)
      @properties ||= new propertiesObj()
      self = this
      @properties.bind 'change', (changedValues) ->
        boundPropertyChanged = false
        for property in boundProperties
          boundPropertyChanged = true if changedValues[property] isnt undefined

        return null unless boundPropertyChanged
        fn.call(self, changedValues)


exports 'EventedObject', EventedObject