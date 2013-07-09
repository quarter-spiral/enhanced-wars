overwrite = require('overwrite')
radio = require('radio')

angular.module('enhancedWars.services', []).
  factory('QSService', ['$rootScope', '$http', 'angularFire', ($rootScope, $http, angularFire) ->
    $rootScope.$safeApply = (fn) ->
      phase = @$root.$$phase
      if phase is "$apply" or phase is "$digest"
        fn()  if fn and (typeof (fn) is "function")
      else
        @$apply fn

    service = {}

    matches = {}

    findFriends = (player) ->
      $http(method: 'GET', url: "#{window.ENV.QS_PLAYERCENTER_BACKEND_URL}/v1/#{player.uuid}/friends?oauth_token=#{service.qs.data.tokens.qs}&game=#{service.qs.data.info.game}").
          success((data, status, headers, config) ->
            service.friends = data
          )

    service.createMatch = (match) ->
      creatorUuid = service.firebaseUser.auth.uuid
      matchToStore = {
        map: match.map || angular.fromJson(match.mapJson)
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
            state: if uuid is creatorUuid then 'playing' else 'invited'
          service.firebaseRef.child("v2/matches").child(uuid).child(matchUuid).set(player)

    service.matchData = (matchUuid) ->
      return matches[matchUuid] if matches[matchUuid]
      match = {}
      matches[matchUuid] = match

      service.firebaseRef.child('v2/matchData').child(matchUuid).on('value', (snapshot) ->
        retrievedMatch= snapshot.val()
        playerUuids = []
        playerUuids.push playerUuid for playerUuid, junk of retrievedMatch.players
        if playerUuids.length > 0 then playerUuids = "uuids[]=#{playerUuids.join('&uuids[]=')}" else ''

        $http(method: 'GET', url: "#{window.ENV.QS_PLAYERCENTER_BACKEND_URL}/v1/public/players?oauth_token=#{service.qs.data.tokens.qs}&#{playerUuids}").
            success((data, status, headers, config) ->
              for uuid, venueData of data
                retrievedMatch.players[uuid] = venueData.venues[service.qs.data.info.venue]
            )
        overwrite(match, retrievedMatch)
        $rootScope.$safeApply()
      )
      match

    service.joinMatch = (matchUuid) ->
      myUuid = service.firebaseUser.auth.uuid
      service.firebaseRef.child('v2/matchData').child(matchUuid).child('players').child(myUuid).set(true)
      service.firebaseRef.child('v2/matches').child(myUuid).child(matchUuid).child('state').set('playing')

    service.openMatch = (match) ->
      Game = require('Game')
      if window.game and window.game.init isnt undefined
        window.game.init(match.map)
      else
        window.game = new Game(map: match.map)

    radio('ew/game/actions/updated').subscribe (game, action) ->
      $rootScope.maxActionSteps = game.actions.length - 1
      $rootScope.$safeApply()
      $rootScope.actionStep = game.actions.length - 1
      $rootScope.$safeApply()

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