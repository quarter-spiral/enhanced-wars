angular.module('enhancedWars.controllers', ['enhancedWars.services', 'enhancedWars.defaultMaps']).
  controller('GamesController', ['$rootScope', '$scope', '$routeParams', '$location', 'angularFire', 'QSService', 'DefaultMaps', ($rootScope, $scope, $routeParams, $location, angularFire, QSService, DefaultMaps) ->

    unless $rootScope.params
      jQuery = require('jquery')
      $rootScope.params = $routeParams
      openMatch = (matchUuid) ->
        if jQuery('#game').length < 1
          setTimeout((-> openMatch(matchUuid)), 100)
          return

        QSService.matchData matchUuid, (match) ->
          QSService.openMatch(match)

      $rootScope.$watch 'params.matchUuid', ->
        unless $rootScope.params.matchUuid
          jQuery('#game').hide()
          return
        jQuery('#game').show()
        openMatch($rootScope.params.matchUuid)

    $rootScope.showChat = false if $rootScope.showChat is undefined
    $rootScope.showChatIcon = false if $rootScope.showChatIcon is undefined

    $rootScope.$on('$routeChangeStart', (scope, next, current) ->
      $rootScope.showChatIcon = !!next.pathParams.matchUuid
      $rootScope.showChat = false
    )

    $scope.matchData = (matchUuid) ->
      QSService.matchData(matchUuid)

    $scope.notLoggedIn = ->
      QSService.notLoggedIn

    $scope.player = ->
      QSService.player

    $scope.loaded = ->
      QSService.player or QSService.notLoggedIn

    $scope.defaultMaps = DefaultMaps

    $scope.cloneMap = (map) ->
      angular.fromJson(angular.toJson(map))

    $scope.openMatch = (matchUuid) ->
      $location.path("/match/#{matchUuid}")

    $scope.playerGames = [
      {currentTurn:true, pace:'fast'}
      {currentTurn:false, playing:"John", pace:'fast'}
      {currentTurn:true, pace:'slow'}
      {currentTurn:false, playing:"Kevin", pace:'medium'}
      {currentTurn:false, playing:"Jane", pace:'fast'}
      {currentTurn:false, playing:"Karen", pace:'slow'}
      {currentTurn:true, pace:'fast'}
      {currentTurn:false, playing:"Sebastian", pace:'medium'}
    ]

    $scope.availableGames = [
      {pace:'fast'}
      {pace:'fast'}
      {pace:'medium'}
      {pace:'medium'}
      {pace:'slow'}
      {pace:'slow'}
      {pace:'slow'}
      {pace:'slow'}
    ]

    $scope.friends = ->
      QSService.friends

    $scope.qsData = ->
      QSService.qs.data

    $scope.createMatch = (match) ->
      matchUuid = QSService.createMatch(match)
      $location.path("/match/#{matchUuid}")

    $scope.joinMatch = (matchUuid) ->
      QSService.joinMatch(matchUuid, -> $scope.openMatch(matchUuid))

    $scope.publicMatches = () ->
      uuid for uuid, state of $rootScope.publicMatches when state is 'open'

    $scope.countPublicMatches = (paceSetting) ->
      i = 0
      for uuid, state of $rootScope.publicMatches when state is 'open'
        if $scope.matchData(uuid).pace == paceSetting
          i++
      i

    $scope.currentlyPlaying = (matches) ->
      return unless matches
      result = {}
      result[uuid] = match for uuid, match of matches when match.state is 'playing'
      result

    $scope.myTurn = (matches) ->
      return unless matches
      result = {}
      for uuid, match of $scope.currentlyPlaying(matches)
        QSService.matchData uuid, (match) ->
          result[uuid] = match if match.currentPlayer is QSService.myUuid() or match.currentPlayer is 'ended'
      result

    $scope.notMyTurn = (matches) ->
      return unless matches
      result = {}
      for uuid, match of $scope.currentlyPlaying(matches)
        QSService.matchData uuid, (match) ->
          result[uuid] = match if match.currentPlayer isnt QSService.myUuid()

      result

    $scope.endedMatches = (matches) ->
      return unless matches
      result = {}
      result[uuid] = match for uuid, match of matches when match.state is 'ended'
      result

    $scope.pendingInvitations = (matches) ->
      return unless matches
      result = {}
      result[uuid] = match for uuid, match of matches when match.state is 'invited'
      result

    $scope.goToMatch = (uuid) ->
      url = QSService.matchCanvasUrl(uuid)
      window.parent.location.href = url

    $scope.reloadUrl = ->
      return unless QSService.qs and QSService.qs.data and QSService.qs.data.info
      QSService.qs.data.info.url

    $scope.parentMatchUrl = (uuid) ->
      QSService.matchCanvasUrl(uuid)

    $scope.login = () ->
      urlData = QSService.qs.info.url.match(/^(http.*:\/\/)([^\/]*)(.*)$/)
      scheme = urlData[1]
      hostAndPort = urlData[2]
      path = urlData[3]

      loginUrl = "#{scheme}#{hostAndPort}/auth/auth_backend?origin=#{encodeURIComponent(QSService.qs.info.url)}"
      window.parent.location.href = loginUrl

    $scope.chatMessage = ""

    $scope.addChatMessage = (message) ->
      QSService.addChatMessage(message)
      $scope.chatMessage = ""

    $scope.scrollChatDown = ->
      $('.chat-messages-list').each ->
        self = this
        setTimeout(->
          self.scrollTop = self.scrollHeight
        , 200)

    $scope.forfeitMatch = ->
      QSService.forfeitMatch()

    DefaultRuleSet = require("DefaultRuleSet")
    $scope.currentRuleSet = new DefaultRuleSet()

  ])