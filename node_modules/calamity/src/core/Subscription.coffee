# # Subscription
# Represents a subscription of a handler to an address on an bus.
Subscription = class C.Subscription
	# Constructor.
	constructor: (@address, @handler, @context, @bus) ->
		@id = util.genId()
		@active = true
		return

	# ## `unsubscribe()`
	# Shorthand for unsubscribing.
	unsubscribe: ->
		return unless @active
		@bus.unsubscribe @
		@active = false
		return @

	# ## `trigger()`
	# Fires the handler with the supplied message.
	trigger: (msg) ->
		return @ unless @active
		# Bind handler.
		bound = _.bind @handler, @context
		# Execute.
		bound msg
#		_.defer ->
#			bound msg
#			return

		return @
