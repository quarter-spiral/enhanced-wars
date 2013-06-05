moduleKeywords = ['extended', 'included']

loaded = false
radio = require('radio')
radio('ew/loader/done').subscribe ->
  loaded = true
  while laterIncludes.length > 0
    laterInclude = laterIncludes.pop()
    laterInclude.this.include.call(laterInclude.this, laterInclude.obj)

laterIncludes = []

includeLater = (t, obj)->
  laterIncludes.push(this: t, obj: obj)

class Module
  @include: (obj) ->
    return includeLater(@, obj) unless loaded

    throw('include(obj) requires obj') unless obj

    obj = obj.lazy(@) if obj.lazy isnt undefined

    for key, value of obj.prototype when key not in moduleKeywords
        @::[key] = value

    included = obj.included
    included.apply(this) if included

exports 'Module', Module