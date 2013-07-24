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
  scrollingDoneByUs = false
  alreadyScrolled = false

  priority: 1
  require: ["?ngModel"]
  restrict: "A"
  link: (scope, $el, attrs, ctrls) ->
    jqEl = $(el)

    scrollToBottom = ->
      scrollingDoneByUs = true
      setTimeout((-> el.scrollTop = el.scrollHeight), 200)

    shouldActivateAutoScroll = ->
      !alreadyScrolled || (el.scrollTop + el.clientHeight is el.scrollHeight)
    el = $el[0]
    ngModel = ctrls[0] || fakeNgModel(true)
    scope.$watch(attrs.scrollGlue, ->
      scrollToBottom() if ngModel.$viewValue
    )

    $el.bind "scroll", (e) ->
      alreadyScrolled = true unless scrollingDoneByUs
      scrollingDoneByUs = false
      scope.$apply ngModel.$setViewValue.bind(ngModel, shouldActivateAutoScroll())
