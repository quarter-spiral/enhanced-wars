class NotificationMail
  constructor: (@name, @email, @playerUuid, @matches) ->

  toSendgridOptions: =>
    to: 'info@quarterspiral.com'
    from: 'info@quarterspiral.com'
    subject: "#{@matches.length} Enhanced Wars #{if @matches.length > 1 then 'matches' else 'match'} awaits"
    text: @body()

  body: =>
    "Hey #{@name} (#{@email}),\n\nwe have #{@matches.length} #{if @matches.length > 1 then 'matches' else 'match'} waiting for you at https://enhancedwars.com/\n\nCheers,\n\nyour Quarter Spiral team\n\n\n"

module.exports = NotificationMail