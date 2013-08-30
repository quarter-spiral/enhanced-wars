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

    @matchData = {}

    @auth()
    setInterval(@auth, FIREBASE_TOKEN_RENEWAL_INTERVAL * 1000)

  auth: =>
    @close()
    token = @generateToken()

    winston.info("Authenticating house keeping connection")
    @rootRef.auth token, (error) =>
      throw error if(error)
      @connectMatchData()

  epochTime: ->
    parseInt((new Date).getTime / 1000, 10)

  tokenGenerator: =>
    new FirebaseTokenGenerator(process.env.QS_FIREBASE_SECRET)

  generateToken: =>
    winston.info("Generating new house keeping token")
    @tokenGenerator().createToken({}, expires: @epochTime() + FIREBASE_TOKEN_TTL, admin: true)

  matchDataRef: (matchUuid) =>
    @rootMatchDataRef.child(matchUuid)

  connectMatchData: =>
    @rootMatchDataRef = @rootRef.child('v2/matchData')

    updateMatchData = (snapshot) =>
      @matchData[snapshot.name()] = snapshot.val()
      @trigger('matchDataChanged', [snapshot.name(), snapshot.val()])

    @rootMatchDataRef.on 'child_added', updateMatchData
    @rootMatchDataRef.on 'child_changed', updateMatchData

    @rootMatchDataRef.on('child_removed', (snapshot) =>
      delete @matchData[snapshot.name()]
      @trigger('matchDataChanged', [snapshot.name(), null])
    )

  close: =>
    winston.info("Closing house keeping connection")
    @rootRef.off()
    @rootMatchDataRef.off() if @rootMatchDataRef

module.exports =
  Connection: Connection