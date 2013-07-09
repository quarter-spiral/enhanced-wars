angular.module('enhancedWars', ['enhancedWars.controllers', 'enhancedWars.services', 'enhancedWars.filters', 'enhancedWars.directives', 'firebase']).config(['$routeProvider', ($routeProvider) ->
  $routeProvider.when('/matches', templateUrl: '/app/partials/matches.html', controller: 'GamesController').
    when('/join', templateUrl: '/app/partials/join.html', controller: 'GamesController').
    when('/create', templateUrl: '/app/partials/create.html', controller: 'GamesController').
    when('/gameWaiting', templateUrl: '/app/partials/gameWaiting.html', controller: 'GamesController').
    when('/match/:matchUuid', templateUrl: '/app/partials/match.html', controller: 'GamesController').
    otherwise(redirectTo: '/matches')
])