Task = require('../task.coffee').Task
Match = require('./match.coffee')
NotificationMail = require('./notification-mail.coffee')
ObjectHelper = require('./object-helper.coffee')
http = require('http')
https = require('http')
url = require('url')
sendgrid  = require('sendgrid')(process.env.SENDGRID_USERNAME, process.env.SENDGRID_PASSWORD)

class NotifyPlayerTask extends Task
  id: 'notify-player'

  TEN_MINUTES: 1000 * 60 * 10

  constructor: (@connection) ->
    username = process.env.QS_OAUTH_CLIENT_ID;
    password = process.env.QS_OAUTH_CLIENT_SECRET;
    auth = 'Basic ' + new Buffer(username + ':' + password).toString('base64')
    onToken = (response) =>
      str = ''
      response.on 'data', (chunk) =>
        str += chunk

      response.on 'end', =>
        @token = JSON.parse(str).token
        if @token
          @log("New QS OAuth token created")
        else
          @log("Could not create QS OAuth token!", 'error')

    parsedUrl = url.parse("#{process.env.QS_AUTH_BACKEND_URL}/api/v1/token/app")
    client = parsedUrl.protocol is 'https' then https else http
    client.request({host: parsedUrl.hostname, path: parsedUrl.pathname, port: parsedUrl.port, method: 'POST', headers: {Authorization: auth}}, onToken).end()

  run: (callback) =>
    @checkNotifications(callback)

  getPlayerInfo: (uuids, callback) =>
    onPlayerInfo = (response) =>
      str = ''
      response.on 'data', (chunk) =>
        str += chunk

      response.on 'end', =>
        callback(JSON.parse(str))

    parsedUrl = url.parse("#{process.env.QS_AUTH_BACKEND_URL}/api/v1/users/batch/identities")
    http.request({host: parsedUrl.hostname, path: parsedUrl.pathname + "?uuids=#{encodeURIComponent(JSON.stringify(uuids))}", port: parsedUrl.port, method: 'GET', headers: {Authorization: "Bearer #{@token}"}}, onPlayerInfo).end()

  sendMail: (name, email, playerUuid, matches, onDone) =>
    @log("Sending notification email to #{name} (#{email})")

    count = matches.length

    mail = new NotificationMail(name, email, playerUuid, matches)
    sendgrid.send mail.toSendgridOptions(), (err, json) =>
      if (err)
        @log(err.message, 'error')
      else
        @log("Notification mail sent: " + json)

    for match in matches
      match.lastActionOf playerUuid, (lastAction, rawAction) =>
        @connection.refs.matchData.child(match.uuid).child('turnAtLastEmail').child(playerUuid).set(rawAction.index)
        count -= 1
        onDone() if count is 0

  checkNotifications: (callback) =>
    if !@connection || !@token
      callback()
      return

    jobCount = ObjectHelper.size(@connection.matchData)

    if jobCount is 0
      callback()
      return

    playersToNotify = {}

    jobDone = (needsNotification, match) =>
      if needsNotification
        playerIndex = match.playerByIndex(match.actualCurrentPlayerIndex())
        playersToNotify[playerIndex] ||= []
        playersToNotify[playerIndex].push(match)

      jobCount -= 1
      if jobCount < 1
        uuids = []
        for playerUuid, matches of playersToNotify
          uuids.push playerUuid

        @getPlayerInfo uuids, (playerData) =>
          count = ObjectHelper.size(playersToNotify)

          for playerUuid, matches of playersToNotify
            name = playerData[playerUuid].venues.embedded.name
            email = playerData[playerUuid].venues.embedded.email

            @log("Notify #{playerUuid} - #{name} - #{email} of #{matches.length} games.")

            if name? and email? and email isnt 'unknown@example.com'
              @sendMail name, email, playerUuid, matches, ->
                count -= 1
                callback() if count is 0
            else
              count -= 1
              callback() if count is 0

    for matchUuid, matchData of @connection.matchData
      @gatherNotificationsFor(matchUuid, matchData, jobDone)


  gatherNotificationsFor: (matchUuid, matchData, callback) =>
    match = new Match(matchUuid, matchData)

    d = new Date()
    currentUtcTimestamp = new Date(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds(), d.getUTCMilliseconds()).getTime()
    tenMinutesAgo = currentUtcTimestamp - @TEN_MINUTES

    currentPlayer = match.playerByIndex(match.actualCurrentPlayerIndex())
    match.lastActionOf currentPlayer, (lastAction, rawLastAction) ->
      weAreNotSpamming = !(match.turnAtLastEmail(currentPlayer)?) || match.turnAtLastEmail(currentPlayer) isnt rawLastAction.index
      needsNotification = lastAction? and lastAction.timestamp? and lastAction.timestamp < tenMinutesAgo and match.actualCurrentPlayer() is match.playerByIndex(match.actualCurrentPlayerIndex()) and weAreNotSpamming

      callback(needsNotification, match)

module.exports = NotifyPlayerTask