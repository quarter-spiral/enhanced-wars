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
        currentPlayer: creatorUuid
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

    service.matchData = (matchUuid, callback) ->
      if matches[matchUuid]
        callback(matches[matchUuid]) if callback
        return matches[matchUuid]

      match = {}
      matches[matchUuid] = match

      service.firebaseRef.child('v2/matchData').child(matchUuid).on('value', (snapshot) ->
        retrievedMatch = snapshot.val()
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
        callback(match) if callback
      )
      match

    service.joinMatch = (matchUuid) ->
      myUuid = service.firebaseUser.auth.uuid
      match = service.matchData(matchUuid, (match) ->
        matchDataRef = service.firebaseRef.child('v2/matchData').child(matchUuid)
        matchDataRef.child('players').child(myUuid).set(true)
        matchDataRef.child('currentPlayer').set(myUuid) if match.currentPlayer is 'open-invitation'
        service.firebaseRef.child('v2/matches').child(myUuid).child(matchUuid).child('state').set('playing')
      )

    service.nextPlayer = (matchUuid) ->
      match = service.matchData(matchUuid)
      firstPlayer = null
      for player, junk of match.players
        firstPlayer ||= player
        return player if nextExit
        nextExit = true if player is match.currentPlayer
      return firstPlayer if nextExit
      undefined

    currentActionRef = null
    rendererReady = false
    reactOnAction = (dataSnapshot) ->
      {action, index} = dataSnapshot.val()
      unless window.game.actions[index]
        window.game.onready =>
          Action = require('Action')
          action = Action.load(action)
          window.game.actions.push(action)
          if rendererReady
            window.game.seekToAction(window.game.actions.length - 1)
            radio('ew/game/actions/updated').broadcast(game)

    mapReady = false
    unitsReady = false

    kickOff = ->
      return unless mapReady and unitsReady
      return if window.game.actions.length < 1
      window.game.seekToAction(window.game.actions.length - 1)
      rendererReady = true
      radio('ew/game/actions/updated').broadcast(game)
      setTimeout(window.game.gameRenderer.update, 200)
      setTimeout(window.game.gameRenderer.update, 1000)

    radio('ew/game/map/loaded').subscribe ->
      mapReady = true
      kickOff()

    radio('ew/game/units/loaded').subscribe ->
      unitsReady = true
      kickOff()

    service.openMatch = (match) ->
      Game = require('Game')
      if window.game and window.game.init isnt undefined
        window.game.init(match.map, match)
      else
        window.game = new Game(map: match.map, match: match)

      currentActionRef.off('child_added', reactOnAction) if currentActionRef
      currentActionRef = service.firebaseRef.child('v2/matchData').child($rootScope.params.matchUuid).child('actions')
      currentActionRef.on('child_added', reactOnAction)

    radio('ew/game/actions/updated').subscribe (game, action) ->
      $rootScope.maxActionSteps = game.actions.length - 1
      $rootScope.$safeApply()
      $rootScope.actionStep = game.actions.length - 1
      $rootScope.$safeApply()
      if action
        service.firebaseRef.child('v2/matchData').child($rootScope.params.matchUuid).child('actions').push(action: action.dump(), index: game.actions.indexOf(action))

        if action.actionClass is 'NextTurnAction'
          nextPlayer = service.nextPlayer($rootScope.params.matchUuid)
          nextPlayer ||= 'open-invitation'
          service.firebaseRef.child('v2/matchData').child($rootScope.params.matchUuid).child('currentPlayer').set(nextPlayer)

    QS.setup().then((qs) ->
      service.qs = qs
      qs.retrievePlayerInfo().then((player) ->
        service.player = player
        window.player = player
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
        service.qs = error.data
        service.notLoggedIn = true
        $rootScope.$apply()
      else
        throw(error.message)
    )

    service
  ])