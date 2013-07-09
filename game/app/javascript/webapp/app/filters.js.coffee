keys = (object) ->
  result = []
  return result unless object
  result.push(key) for key, value of object
  result

angular.module('enhancedWars.filters', []).filter("emptyObject", ->
  (object) ->
    keys(object).length < 1
).filter('keys', ->
  (object) ->
    keys(object)
).filter('nKeys', ->
  (object, numberOfKeys) ->
    keys(object).length == numberOfKeys
)