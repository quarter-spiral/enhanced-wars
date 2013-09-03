Calamity = require('calamity')
Firebase = require('firebase')
FirebaseTokenGenerator = require("firebase-token-generator")
winston = require("winston")

class Connection
  Calamity.emitter @prototype

  THIRTY_MINUTES = 30 * 60
  TWENTY_MINUTES = 20 * 60

  FIREBASE_TOKEN_TTL = THIRTY_MINUTES
  FIREBASE_TOKEN_RENEWAL_INTERVAL = TWENTY_MINUTES

  constructor: ->
    @rootRef = new Firebase(process.env.QS_FIREBASE_URL)
    @refs = {}

    @matchData = {}
    @publicChatMessages = {}

    @auth()
    setInterval(@auth, FIREBASE_TOKEN_RENEWAL_INTERVAL * 1000)

  auth: =>
    @close()
    token = @generateToken()

    winston.info("Authenticating house keeping connection")
    @rootRef.auth token, (error) =>
      throw error if(error)
      @connectData()

  epochTime: ->
    parseInt((new Date).getTime / 1000, 10)

  tokenGenerator: =>
    new FirebaseTokenGenerator(process.env.QS_FIREBASE_SECRET)

  generateToken: =>
    winston.info("Generating new house keeping token")
    @tokenGenerator().createToken({}, expires: @epochTime() + FIREBASE_TOKEN_TTL, admin: true)

  connectData: =>
    @connectResource @matchData, 'matchData', 'v2/matchData', (matchData, snapshot, onComplete) ->
      matchData.players = []
      snapshot.ref().child('players').once 'value', (snapshot) ->
        playerCount = snapshot.numChildren()
        snapshot.forEach (playerSnapshot) ->
          matchData.players.push playerSnapshot.name()
          onComplete() if matchData.players.length is playerCount

    @connectResource(@publicChatMessages, 'publicChatMessages', 'v2/publicChatMessages')

  connectResource: (dataContainer, resourceName, refName, callback) =>
    ref = @rootRef.child(refName)
    @refs[resourceName] = ref

    changeEventName = "#{resourceName}Changed"

    update = (snapshot) =>
      onDone = (val) =>
        dataContainer[snapshot.name()] = val
        @trigger(changeEventName, [snapshot.name(), val])

      if callback
        val = snapshot.val()
        callback val, snapshot, ->
          onDone(val)
      else
        onDone(snapshot.val())

    ref.on 'child_added', update
    ref.on 'child_changed', update

    ref.on('child_removed', (snapshot) =>
      delete dataContainer[snapshot.name()]
      @trigger(changeEventName, [snapshot.name(), null])
    )

  close: =>
    winston.info("Closing house keeping connection")
    @rootRef.off()
    for resourceName, ref of @refs
      ref.off()
      delete @refs[resourceName]

module.exports =
  Connection: Connection