angular.module('enhancedWars.services', []).
  factory('QSService', ['$rootScope', '$http', 'angularFire', ($rootScope, $http, angularFire) ->
    service = {}

    findFriends = (player) ->
      $http(method: 'GET', url: "#{window.ENV.QS_PLAYERCENTER_BACKEND_URL}/v1/#{player.uuid}/friends?oauth_token=#{service.qs.data.tokens.qs}&game=#{service.qs.data.info.game}").
          success((data, status, headers, config) ->
            service.friends = data
          )

    service.createMatch = (match) ->
      creatorUuid = service.firebaseUser.auth.uuid
      matchToStore = {
        map: match.map
        players: {}
        type: match.type
      }
      matchToStore.players[creatorUuid] = true
      matchDataRef = service.firebaseRef.child('v2/matchData').push();
      matchDataRef.set(matchToStore)
      matchUuid = matchDataRef.name()

      for uuid, value of match.invitations
        if value is '1'
          friend = service.friends[uuid][service.qs.data.info.venue]
          player =
            uuid: uuid
            name: friend.name
            state: if uuid is creatorUuid then 'playing' else 'invited'
          service.firebaseRef.child("v2/matches").child(uuid).child(matchUuid).set(player)

    QS.setup().then((qs) ->
      service.qs = qs
      qs.retrievePlayerInfo().then((player) ->
        service.player = player
        findFriends(player)

        firebaseUrl = window.ENV.QS_FIREBASE_URL
        firebaseRef = new Firebase(firebaseUrl)
        service.firebaseRef = firebaseRef
        firebaseRef.auth(player['firebase-token'], (error, user) ->
          if error
            throw(error.message)
          else if user
            service.firebaseUser = user
            resourceUrl = firebaseUrl + "/v2/matches/#{user.auth.uuid}"
            angularFire(resourceUrl, $rootScope, "playerMatches", {})

            $rootScope.$apply()
        )

        $rootScope.$apply()

#         var Game = require('Game');
#         window.game = new Game({map: mapToLoad});
      , (error) ->
        throw(error.message)
      )
    , (error) ->
      if error.message is 'Not logged in'
        service.notLoggedIn = true
        $rootScope.$apply()
      else
        throw(error.message)
    )

    service
  ])