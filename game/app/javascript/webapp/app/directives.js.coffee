angular.module('enhancedWars.directives', []).directive "actionRangeChange", ($rootScope) ->
  radio = require('radio')
  linker = (scope, element, attrs) ->
    updateScope = ->
      $rootScope.actionStep = element.val()
      radio('ew/input/actions/seek').broadcast(element.val())

    $rootScope.$watch 'actionStep', ->
      element.val($rootScope.actionStep)

    element.bind "change", updateScope
    updateScope() #get the default value

  link: linker
