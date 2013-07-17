angular.module('enhancedWars.controllers', ['enhancedWars.services', 'enhancedWars.defaultMaps']).
  controller('GamesController', ['$rootScope', '$scope', '$routeParams', 'angularFire', 'QSService', 'DefaultMaps', ($rootScope, $scope, $routeParams, angularFire, QSService, DefaultMaps) ->
    unless $rootScope.params
      jQuery = require('jquery')
      $rootScope.params = $routeParams
      $rootScope.openMatch = (matchUuid) ->
        openMatch = ->
          if jQuery('#game').length < 1
            setTimeout(openMatch, 100)
            return
          QSService.openMatch(QSService.matchData(matchUuid))
        openMatch()

      $rootScope.$watch 'params.matchUuid', ->
        unless $rootScope.params.matchUuid
          jQuery('#game').hide()
          return
        jQuery('#game').show()
        $rootScope.openMatch($rootScope.params.matchUuid)

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
      QSService.createMatch(match)

    $scope.joinMatch = (matchUuid) ->
      QSService.joinMatch(matchUuid)

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
          result[uuid] = match if match.currentPlayer is QSService.myUuid()
      result

    $scope.notMyTurn = (matches) ->
      return unless matches
      result = {}
      for uuid, match of $scope.currentlyPlaying(matches)
        QSService.matchData uuid, (match) ->
          result[uuid] = match if match.currentPlayer isnt QSService.myUuid()

      result

    $scope.pendingInvitations = (matches) ->
      return unless matches
      result = {}
      result[uuid] = match for uuid, match of matches when match.state is 'invited'
      result

    $scope.login = () ->
      urlData = QSService.qs.info.url.match(/^(http.*:\/\/)([^\/]*)(.*)$/)
      scheme = urlData[1]
      hostAndPort = urlData[2]
      path = urlData[3]

      loginUrl = "#{scheme}#{hostAndPort}/auth/auth_backend?origin=#{encodeURIComponent(QSService.qs.info.url)}"
      window.parent.location.href = loginUrl
  ])