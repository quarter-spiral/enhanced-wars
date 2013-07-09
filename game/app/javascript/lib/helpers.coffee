clone = (obj) ->
  if not obj? or typeof obj isnt 'object'
    return obj

  if obj instanceof Date
    return new Date(obj.getTime())

  if obj instanceof RegExp
    flags = ''
    flags += 'g' if obj.global?
    flags += 'i' if obj.ignoreCase?
    flags += 'm' if obj.multiline?
    flags += 'y' if obj.sticky?
    return new RegExp(obj.source, flags)

  newInstance = new obj.constructor()

  for key of obj
    newInstance[key] = clone obj[key]

  return newInstance

exports('clone', clone)

extend = (object, properties) ->
  for key, val of properties
    object[key] = val
  object

exports('extend', extend)

merge = (options, overrides) ->
  extend (extend {}, options), overrides

exports('merge', merge)

overwrite = (object, newData) ->
  delete object[key] for key, val of object
  for key, val of newData
    object[key] = val
exports 'overwrite', overwrite

typeIsArray = Array.isArray || ( value ) -> return {}.toString.call( value ) is '[object Array]'
exports 'typeIsArray', typeIsArray