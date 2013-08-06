keys = (object) ->
  result = []
  return result unless object
  result.push(key) for key, value of object
  result

autoLink = (options...) ->
  pattern = ///
    (^|\s) # Capture the beginning of string or leading whitespace
    (
      (?:https?|ftp):// # Look for a valid URL protocol (non-captured)
      [\-A-Z0-9+\u0026@#/%?=~_|!:,.;]* # Valid URL characters (any number of times)
      [\-A-Z0-9+\u0026@#/%=~_|] # String must end in a valid URL character
    )
  ///gi

  return @replace(pattern, "$1<a href='$2'>$2</a>") unless options.length > 0

  option = options[0]
  linkAttributes = (
    " #{k}='#{v}'" for k, v of option when k isnt 'callback'
  ).join('')

  @replace pattern, (match, space, url) ->
    link = option.callback?(url) or
      if url.match(/\.jpg$/) or url.match(/\.jpeg$/) or url.match(/\.gif$/) or url.match(/\.png$/)
        "<a href='#{url}'#{linkAttributes}><img src='#{url}'/></a>"
      else
        "<a href='#{url}'#{linkAttributes}>#{url}</a>"

    "#{space}#{link}"
String.prototype['autoLink'] = autoLink

angular.module('enhancedWars.filters', []).filter("emptyObject", ->
  (object) ->
    keys(object).length < 1
).filter('keys', ->
  (object) ->
    keys(object)
).filter('nKeys', ->
  (object, numberOfKeys) ->
    keys(object).length == numberOfKeys
).filter('autoLink', ->
  (str) ->
    return str unless str.autoLink
    str.autoLink(target: "_blank", rel: "nofollow")
)