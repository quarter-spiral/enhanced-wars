# # EventBus
# Manages passing events from publishers to subscribers.
EventBus = class C.EventBus
	constructor: ->
		# Generate ID.
		@id = util.genId()
		# Registered subscriptions container.
		@_subscriptions = {}
		# Registered bridges container.
		@_bridges = []

	# ## `subscribe()`
	# Register a handler to an address.
	subscribe: (address, handler, context) ->
		# Initialize subscriptions container for this address.
		unless @_subscriptions[address]
			@_subscriptions[address] = []
		# Create subscription.
		sub = new Subscription address, handler, context, @
		# Add to list.
		@_subscriptions[address].push sub
		# Send to bridges.
		@_bridgeProp "subscribe", subscription: sub
		# Return subscription.
		return sub

	# ## `unsubscribe()`
	# Unsubscribes a handler.
	unsubscribe: (address, handler) ->
		sub = address
		# Search by subscription.
		if sub instanceof Subscription
			# Check address.
			address = sub.address
			return unless @_subscriptions[address]
			for s, i in @_subscriptions[address]
				if s is sub
					@_subscriptions[address].splice i
		# Otherwise search by address and handler.
		else
			# Check for address.
			return unless @_subscriptions[address]
			for s, i in @_subscriptions[address]
				if s.address is address and s.handler is handler
					sub = s
					@_subscriptions[address].splice i
		# Send to bridges.
		@_bridgeProp "unsubscribe", subscription: sub
		return

	# ## `publish()`
	# Publishes an event to a all subscribers on an address.
	publish: (address, data, reply) ->
		msg = @_createMessage address, data, reply
		address = msg.address
		# Check if message has already been processed by this bus.
		return @ if msg.sawBus @
		# Register this bus on the event
		msg.addBus @
		# Publish to target address.
		@_publishAddress address, msg
		# Publish to wildcard address.
		@_publishAddress "*", msg
		# Send to bridges.
		@_bridgeProp "publish", message: msg

		return @

	# ## `send()`
	# Sends an event to a single subscribed address.
	# Sends are sent to wildcard addresses, ever.
	send: (address, data, reply) ->
		msg = @_createMessage address, data, reply
		address = msg.address
		# Check if message has already been processed by this bus.
		return @ if msg.sawBus @
		# Register this bus on the event
		msg.addBus @
		# Publish to target address.
		@_sendAddress address, msg
		# Send to bridges.
		@_bridgeProp "send", message: msg

		return @

	# ## `bridge()`
	# Attached a bridge object to this bus.
	# Briges will receive information about everything that's going on.
	bridge: (bridge) ->
		throw new Error "Briges must extend Calamity.EventBridge" unless bridge instanceof EventBridge
		@_bridges.push bridge unless _.contains @_bridges, bridge
		return @

	# Utility function for creating messages.
	_createMessage: (address, data, reply) ->
		# Construct new EventMessage is necesarry.
		msg = address
		unless msg instanceof EventMessage
			msg = new EventMessage address, data, reply
		return msg

	# Publishes a message to an address.
	_publishAddress: (address, msg) ->
		# Check if we have subscriptions at all for this address.
		return unless @_subscriptions[address]
		# Send message to all subscriptions.
		for subscription in @_subscriptions[address]
			subscription.trigger msg
		return

	# Sends a message to an address.
	_sendAddress: (address, msg) ->
		# Check if we have subscriptions at all for this address.
		return unless @_subscriptions[address]
		# Send message to a single random subscription.
		subs = @_subscriptions[address]
		len = subs.length
		i = Math.floor(Math.random()*len)
		subs[i].trigger msg
		return

	# Propagates to all bridges.
	_bridgeProp: (type, data) ->
		return unless @_bridges.length > 0
		address = "bus.#{type}"
		data.bus = @
		for b in @_bridges
			b.trigger address, data
		return
