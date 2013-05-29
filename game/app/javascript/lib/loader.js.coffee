exportedObjects = {}

extractNameFromFunction = (fn) ->
  FUNCTION_NAME_REGEX = /function ([^\(]*)\(/
  fn.toString().match(FUNCTION_NAME_REGEX)[1]

@exports = (name, object) ->
  if !object and (typeof name) is 'function'
    object = name
    name = extractNameFromFunction(object)

  exportedObjects[name] = object

@define = (fn) ->
  fn = fn()
  name = extractNameFromFunction(fn)
  exportedObjects[name] = fn
@define.amd = {}

@require = (name) ->
  exportedObjects[name]