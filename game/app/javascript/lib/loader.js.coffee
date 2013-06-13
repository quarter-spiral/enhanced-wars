exportedObjects = {}

extractNameFromFunction = (fn) ->
  FUNCTION_NAME_REGEX = /function ([^\(]*)\(/
  fn.toString().match(FUNCTION_NAME_REGEX)[1]

registeredNeeds = []
self = @
callANeed = (needDefinition) ->
  stack = []
  stack.push(exportedObjects[module]) for module in needDefinition.neededModules
  needDefinition.callback.apply(self, stack)

needsSacrificed = (needDefinition) ->
  loaded = true
  loaded = loaded and exportedObjects[module] for module in needDefinition.neededModules
  loaded

checkForSacrificedNeeds = ->
  i = 0
  stillNeeds = []
  while currentNeed = registeredNeeds.shift()
    if needsSacrificed(currentNeed)
      callANeed(currentNeed)
    else
      stillNeeds.push(currentNeed)
  registeredNeeds.splice(0, registeredNeeds.length)
  registeredNeeds.push(need) for need in stillNeeds

@exports = (name, object) ->
  if !object and (typeof name) is 'function'
    object = name
    name = extractNameFromFunction(object)

  exportedObjects[name] = object
  checkForSacrificedNeeds()
  exportedObjects[name]

@define = (fn) ->
  fn = fn()
  name = extractNameFromFunction(fn)
  exportedObjects[name] = fn
  checkForSacrificedNeeds()
  fn

@define.amd = {}

@require = (name) ->
  exportedObjects[name]

@needs = (neededModules, callback) ->
  needDefinition = {neededModules: neededModules, callback: callback}

  if needsSacrificed(needDefinition)
    callANeed(needDefinition)
  else
    registeredNeeds.push(needDefinition)