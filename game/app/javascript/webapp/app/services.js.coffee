overwrite = require('overwrite')
radio = require('radio')

parseParams = (url) ->
  regex = /[?&]([^=#]+)=([^&#]*)/g
  params = {}
  match = undefined
  params[match[1]] = match[2]  while match = regex.exec(url)
  params

angular.module('enhancedWars.services', []).
  factory('QSService', ['$rootScope', '$http', '$location', 'angularFire', ($rootScope, $http, $location, angularFire) ->
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
        map: if match.mapJson then angular.fromJson(match.mapJson) else  match.map
        players: {}
        type: match.type
        pace: match.pace
        maxPlayers: 2
        currentPlayer: creatorUuid
      }
      matchToStore.players[creatorUuid] = true
      matchDataRef = service.firebaseRef.child('v2/matchData').push();
      matchDataRef.set(matchToStore)
      matchUuid = matchDataRef.name()

      service.firebaseRef.child('v2/publicMatches').child(matchUuid).set('open') if matchToStore.type is 'public'

      for uuid, value of match.invitations
        if value is '1'
          friend = service.friends[uuid][service.qs.data.info.venue]
          player =
            uuid: uuid
            state: if uuid is creatorUuid then 'playing' else 'invited'

          callback = ->
          if uuid is creatorUuid
            callback = (error) ->
              # set again with priority to get sorting right
              matchDataRef.child('players').child(creatorUuid).setWithPriority(true, 0) unless error

          service.firebaseRef.child("v2/matches").child(uuid).child(matchUuid).set(player, callback)


      matchUuid

    loadedMatchData = {}
    matchDataCallbacks = {}
    service.matchData = (matchUuid, callback) ->
      matchDataCallbacks[matchUuid] ||= []

      if matches[matchUuid]
        if callback
          if loadedMatchData[matchUuid]
            callback(matches[matchUuid])
          else
            matchDataCallbacks[matchUuid].push(callback)
        return matches[matchUuid]

      match = {}
      matches[matchUuid] = match

      matchDataCallbacks[matchUuid].push(callback) if callback
      service.firebaseRef.child('v2/matchData').child(matchUuid).on('value', (snapshot) ->
        retrievedMatch = snapshot.val()
        return unless retrievedMatch
        retrievedMatch.uuid = matchUuid
        retrievedMatch.winner = {}
        playerUuids = []
        playerUuids.push playerUuid for playerUuid, junk of retrievedMatch.players

        service.qs.retrievePlayerInfo(playerUuids).then (data) ->
          for uuid in playerUuids when data[uuid]
            playerData = data[uuid].venues[service.qs.data.info.venue]
            retrievedMatch.players[uuid] = playerData

            overwrite(retrievedMatch.winner, playerData) if $rootScope.playerMatches and $rootScope.playerMatches[matchUuid] and $rootScope.playerMatches[matchUuid].winner is uuid
          $rootScope.$safeApply()

        overwrite(match, retrievedMatch)
        $rootScope.$safeApply()
        while callback = matchDataCallbacks[matchUuid].shift()
          callback(match)

        loadedMatchData[matchUuid] = true
      )
      match

    service.joinMatch = (matchUuid, callback) ->
      myUuid = service.firebaseUser.auth.uuid
      match = service.matchData(matchUuid, (match) ->
        if match.type == 'public'
          service.firebaseRef.child('v2/matches').child(myUuid).child(matchUuid).set(state: 'invited', uuid: myUuid)

        numberOfExistingPlayers = 0
        numberOfExistingPlayers += 1 for playerUuid, junk in match.players
        matchDataRef = service.firebaseRef.child('v2/matchData').child(matchUuid)
        matchDataRef.child('players').child(myUuid).setWithPriority(true, numberOfExistingPlayers + 1)
        numberOfPlayers = 0
        numberOfPlayers += 1 for junk, junk2 of match.players

        if match.maxPlayers <= numberOfPlayers
          matchDataRef.child('full').set(true)
          service.firebaseRef.child('v2/publicMatches').child(matchUuid).set('in-progress') if match.type == 'public'

        matchDataRef.child('currentPlayer').set(myUuid) if match.currentPlayer is 'open-invitation'
        service.firebaseRef.child('v2/matches').child(myUuid).child(matchUuid).child('state').set('playing', (error) ->
          throw(error) if error
          callback()
        )
      )

    service.nextPlayer = (matchUuid) ->
      match = service.matchData(matchUuid)
      firstPlayer = null
      currentPlayer = match.currentPlayer
      for player, junk of match.players
        firstPlayer ||= player
        return player if nextExit
        nextExit = true if player is match.currentPlayer
      return firstPlayer if nextExit and currentPlayer isnt firstPlayer
      undefined

    service.forfeitMatch = ->
      window.game.forfeit(service.myUuid())

    currentActionRef = null
    rendererReady = false
    matchActionsLoaded = false

    isAtLastActionFinalizeTimeout = null
    isAtLastActionFinalizer = ->
      radio('ew/game/actions/initially-loaded').broadcast()
      matchActionsLoaded = true

    reactOnAction = (dataSnapshot) ->
      {action, index} = dataSnapshot.val()

      unless window.game.actions[index]
        applier = =>
          Action = require('Action')
          action = Action.load(action)
          window.game.actions.push(action)
          if window.game.gameRenderer.ready
            window.game.seekToAction(window.game.actions.length - 1)
            radio('ew/game/actions/updated').broadcast(game)
            radio('ew/game/won').broadcast(window.game.winner()) if window.game and window.game.winner()
        applier.limit = 1
        window.game.onready(applier)
      if window.game.isAtLastAction() and !matchActionsLoaded
        clearTimeout(isAtLastActionFinalizeTimeout) if isAtLastActionFinalizeTimeout
        isAtLastActionFinalizeTimeout = setTimeout(isAtLastActionFinalizer, 500)

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

    winGame = (winner, game) ->
      unless game.hasEndingAction()
        setTimeout((-> winGame(winner, game)), 200)
        return

      matchUuid = game.match.uuid
      matchRef = service.firebaseRef.child('v2/matches').child(service.myUuid()).child(matchUuid)
      matchRef.child("state").set("ended")
      winnerUuid = if (winner and winner.get('uuid')) then winner.get('uuid') else 'none'
      matchRef.child("winner").set(winnerUuid)

      service.firebaseRef.child('v2/matchData').child(matchUuid).child('currentPlayer').set('ended')

      if winnerUuid is 'none'
        service.firebaseRef.child('v2/publicMatches').child(matchUuid).set('in-progress') if $rootScope.publicMatches[matchUuid]
        $location.path("/matches")

    radio('ew/game/won').subscribe (player) ->
      game = player.get('game')
      winner = game.winner()
      return unless winner
      winGame(winner, game)

    service.matchChatRef = (match) ->
      service.firebaseRef.child('v2/matchData').child(match.uuid).child('chat')

    service.openMatch = (match) ->
      Game = require('Game')

      if window.game and window.game.init isnt undefined
        window.game.init(match.map, match)
      else
        window.game = new Game(map: match.map, match: match)
      currentActionRef.off('child_added', reactOnAction) if currentActionRef

      matchActionsLoaded = false
      currentActionRef = service.firebaseRef.child('v2/matchData').child(match.uuid).child('actions')
      currentActionRef.on('child_added', reactOnAction)

      matchChatKey = "matchChat-#{match.uuid}".replace(/-+/g, '')
      unless $rootScope[matchChatKey]
        matchChatRef = service.matchChatRef(match).limit(150)
        angularFire(matchChatRef, $rootScope, matchChatKey, {})

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


    service.chatRef = (forceChannel) ->
      return service.matchChatRef(window.game.match) if forceChannel is 'match'
      return service.firebaseRef.child("/v2/publicChatMessages") if forceChannel is 'public'

      if $location.path().match(/^\/match\//)
        service.matchChatRef(window.game.match)
      else
        service.firebaseRef.child("/v2/publicChatMessages")

    service.addChatMessage = (message, forceChannel) ->
      return if message.match(/^\s*$/)
      newMessageRef = service.chatRef(forceChannel).push()
      newMessageRef.set(author: service.firebaseUser.auth.name, authorUuid: service.myUuid(), messageText: message, time: new Date().getTime())
      $rootScope.$safeApply()

    service.matchCanvasUrl = (uuid) ->
      url = '' + service.qs.data.info.url
      url.replace(/\?.*$/, '') + '?ew_match=' + uuid

    service.myUuid = ->
      service.firebaseUser.auth.uuid

    setTimeout(->
      return if service.player or service.notLoggedIn
      $rootScope.loadTimedOut = true
      $rootScope.$safeApply()
    , 10000)

    QS.setup().then((qs) ->
      service.qs = qs
      window.qs = qs.data

      qs.retrievePlayerInfo().then((player) ->
        service.player = player
        window.player = player
        $rootScope.player = player
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

            resourceUrl = firebaseUrl + "/v2/publicMatches"
            angularFire(resourceUrl, $rootScope, "publicMatches", {})

            resourceUrl = firebaseUrl + "/v2/publicChatMessages"
            publicChatRef = new Firebase(resourceUrl).limit(150)
            angularFire(publicChatRef, $rootScope, "publicChatMessages", {})


            $rootScope.$watch 'playerMatches', ->
              resourceUrl = firebaseUrl + "/v2/matches"
              deleterRef = new Firebase(resourceUrl).child(user.auth.uuid)

              for matchUuid, inviteData of $rootScope.playerMatches when inviteData.state isnt 'ended'
                # Delete full matches
                service.matchData matchUuid, (match) ->
                  matchIsEndedAndIAmInvited = match.currentPlayer is 'ended' and inviteData.state is 'invited'
                  matchIsFull = match.full and !match.players[service.firebaseUser.auth.uuid]
                  if matchIsFull or matchIsEndedAndIAmInvited
                    deleterRef.child(match.uuid).remove()
                    $rootScope.$safeApply()

            $rootScope.$apply()
            if paramMatchUuidToLoad = parseParams(qs.data.info.url).ew_match
              $location.path("/match/#{paramMatchUuidToLoad}")
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