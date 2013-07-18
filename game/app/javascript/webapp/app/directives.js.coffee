fakeNgModel = (initValue) ->
  $setViewValue: (value) ->
    @$viewValue = value

  $viewValue: initValue

angular.module('enhancedWars.directives', []).directive("actionRangeChange", ($rootScope) ->
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
).directive "scrollGlue", ->
  # By Luegg / https://github.com/Luegg/angularjs-scroll-glue/blob/master/src/scrollglue.js
  priority: 1
  require: ["?ngModel"]
  restrict: "A"
  link: (scope, $el, attrs, ctrls) ->
    scrollToBottom = ->
      el.scrollTop = el.scrollHeight
    shouldActivateAutoScroll = ->
      el.scrollTop + el.clientHeight is el.scrollHeight
    el = $el[0]
    ngModel = ctrls[0] || fakeNgModel(true)
    scope.$watch(attrs.scrollGlue, ->
      scrollToBottom() if ngModel.$viewValue
    )

    $el.bind "scroll", ->
      scope.$apply ngModel.$setViewValue.bind(ngModel, shouldActivateAutoScroll())
