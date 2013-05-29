exportedObjects = {}

extractNameFromFunction = (fn) ->
  FUNCTION_NAME_REGEX = /function ([^\(]*)\(/
  fn.toString().match(FUNCTION_NAME_REGEX)[1]

@exports = (name, object) ->
  if !object and (typeof name) is 'function'
    object = name
    name = extractNameFromFunction(object)

  exportedObjects[name] = object

@require = (name) ->
  exportedObjects[name]