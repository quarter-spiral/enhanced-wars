angular.module('enhancedWars', ['enhancedWars.controllers', 'enhancedWars.services', 'enhancedWars.filters', 'enhancedWars.directives', 'firebase']).config(['$routeProvider', ($routeProvider) ->
  $routeProvider.
    when('/matches', templateUrl: '/app/partials/matches.html', controller: 'GamesController').
    when('/join', templateUrl: '/app/partials/join.html', controller: 'GamesController').
    when('/specifications', templateUrl: '/app/partials/specs.html', controller: 'GamesController').
    when('/create', templateUrl: '/app/partials/create.html', controller: 'GamesController').
    when('/gameWaiting', templateUrl: '/app/partials/gameWaiting.html', controller: 'GamesController').
    when('/match/:matchUuid', templateUrl: '/app/partials/match.html', controller: 'GamesController').
    when('/about', templateUrl: '/app/partials/about.html', controller: 'AboutController').
    otherwise(redirectTo: '/matches')
]).run ($rootScope, $location) ->
  # register listener to watch route changes
  $rootScope.$watch('player', ->
    return unless $rootScope.player?
    $location.path('/matches') if $location.path() is '/about'
  )

  $rootScope.$on "$routeChangeStart", (event, next, current) ->
    $location.path "/about"  if next.templateUrl isnt "/app/partials/about.html" and !$rootScope.player?