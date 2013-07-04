angular.module('enhancedWars', ['enhancedWars.controllers', 'firebase']).config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/games', templateUrl: '/app/partials/games.html', controller: 'GamesController').
    when('/join', templateUrl: '/app/partials/join.html', controller: 'GamesController').
    when('/create', templateUrl: '/app/partials/create.html', controller: 'GamesController').
    when('/gameWaiting', templateUrl: '/app/partials/gameWaiting.html', controller: 'GamesController').
    when('/game', templateUrl: '/app/partials/game.html', controller: 'GamesController').
    otherwise(redirectTo: '/games')
])
