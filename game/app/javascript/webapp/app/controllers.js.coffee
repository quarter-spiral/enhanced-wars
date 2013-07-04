angular.module('enhancedWars.controllers', ['enhancedWars.services', 'enhancedWars.defaultMaps']).
  controller('GamesController', ['$scope', 'angularFire', 'QSService', 'DefaultMaps', ($scope, angularFire, QSService, DefaultMaps) ->
    $scope.notLoggedIn = ->
      QSService.notLoggedIn
    $scope.player = ->
      QSService.player
    $scope.loaded = ->
      QSService.player or QSService.notLoggedIn

    # QSService.whenPlayerReady ->

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
  ])