# Extending Array's prototype
unless Array::filter
  Array::filter = (callback) ->
    element for element in this when callback(element)

unless Array::detect
  Array::detect = (callback) ->
    this.filter(callback)[0]