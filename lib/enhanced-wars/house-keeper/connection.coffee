Calamity = require('calamity')
Firebase = require('firebase')
FirebaseTokenGenerator = require("firebase-token-generator")

class Connection
  Calamity.emitter @prototype

  THIRTY_MINUTES = 30 * 60

  constructor: ->
    @token = @generateToken()
    @rootRef = new Firebase(process.env.QS_FIREBASE_URL)

    @matchData = {}

    @rootRef.auth @token, (error) =>
      throw error if(error)
      @connectMatchData()

  epochTime: ->
    parseInt((new Date).getTime / 1000, 10)

  tokenGenerator: =>
    new FirebaseTokenGenerator(process.env.QS_FIREBASE_SECRET)

  generateToken: =>
    @tokenGenerator().createToken({}, expires: @epochTime() + THIRTY_MINUTES, admin: true)

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
    @rootRef.off()
    @matchDataRef.off() if @matchDataRef

module.exports =
  Connection: Connection