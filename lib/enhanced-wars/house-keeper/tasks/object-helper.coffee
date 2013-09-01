keys = (object) =>
  k for k,v of object

values: (object) =>
  v for k,v of object

size: (object) =>
  values(object).length

module.exports =
  keys: keys
  values: values
  size: size