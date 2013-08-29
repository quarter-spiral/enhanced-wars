# # EventMessage
# Represents a single message in the system.
EventMessage = class C.EventMessage
	# Constructor.
	constructor: (@address, @data = {}, replyHandler) ->
		# Generate ID.
		@id = util.genId()
		# Remebered busses container.
		# This will store the ID of every bus the event has seen, to prevent repeated execution.
		@_busses = []
		# Check reply handler.
		unless _.isUndefined(replyHandler) or _.isFunction(replyHandler)
			throw new Error "Reply must be a function"
		@_replyHandler = replyHandler
		# Default values.
		@status = "ok"
		@error = null

	# ## `reply()`
	# Executes the reply handler, if this message has one.
	reply: (data, replier) ->
		replyHandler = @_replyHandler
		# Don't do anything if we don't have a reply handler.
		return unless _.isFunction(replyHandler)
		# Wrap data and further replies in another message.
		unless data instanceof EventMessage
			data = new EventMessage null, data, replier
		# Execute.
		replyHandler data
#		_.defer ->
#			replyHandler data
#			return
		return @

	# ## `replyError()`
	# Executes the reply handler with an error instead of a reply.
	replyError: (error, data = {}) ->
		# Ensure meaningful serialization.
		if error instanceof Error
			# Transfer values to data.
			for v in "message,name,stack,fileName,lineNumber,description,number".split(",")
				val = error[v]
				val = val.toString() if val and typeof val.toString is "function"
				data[v] = val
			if typeof error.toString is "function"
				data.string = error.toString()
				error = data.string
				if data.stack
					error += " :: " + data.stack
		# Create new error message.
		msg = new EventMessage null, data
		msg.status = "error"
		msg.error = error
		# Send reply.
		@reply msg
		return @

	# Automatically catches and propagates errors, removing the need to constantly check incoming messages for errors.
	# Example usage:
	#
	#     @send "address", (reply) => msg.catch reply, =>
	#         # your code here, reply will never be an error.
	#
	# In the above example, catch will check reply for errors, and pass them to the reply handler on msg.
	# If no errors are detected, it will execute the supplied handler inside a try/catch block, and pass
	# any errors back through msg.
	# If no reply handler exists on msg, errors will be rethrown, or no try/catch block will be used.
	# The first argument is optional and can be an EventMessage, or any throwable value.
	# If it's falsy, then it's simply ignored and handler is executed.
	catch: (other, handler) ->
		unless handler?
			unless _.isFunction other
				throw new Error "Supplied handler is not a function, #{typeof other} supplied"
			handler = other
			other = undefined
		# If we don't have a reply handler, throw error directly.
		unless _.isFunction @_replyHandler
			# Throw error if we have one.
			if other?
				if other instanceof EventMessage
					if other.isError()
						throw other.error
				else
					other = new Error other unless other instanceof Error
					throw other
			# Execute handler.
			handler other
		# If we have a reply handler, pass errors to it.
		else
			# Pass supplied errors.
			if other?
				if other instanceof EventMessage
					if other.isError()
						@reply other
						return
				else
					other = new Error other unless other instanceof Error
					@replyError other
					return
			# Execute handler inside try/catch block.
			try
				handler other
			catch err
				@replyError err
		return

	# ## `isSuccess()`
	# Returns true if this message is marked successful, which is the default state.
	isSuccess: ->
		return @status is "ok"

	# ## `isError()`
	# Returns true if this message is marked as errored, such as when replying with `replyError()`.
	isError: ->
		return @status is "error"

	# Returns a parameter message data.
	# If the parameter is not present, `def` is returned.
	getOptional: (param, def) ->
		parts = param.split "."
		val = @data[parts[0]]
		# Iterate from second element onwards.
		if parts.length > 1 then for part in parts.splice 1
			if _.isObject(val) and val[part]?
				val = val[part]
			else
				val = undefined
				break
		# Default.
		if typeof val is "undefined"
			return def
		return val

	# Returns a parameter message data.
	# If the parameter is not present, an error is thrown.
	getRequired: (param) ->
		val = @getOptional param
		if typeof val is "undefined"
			throw new Error "Variable \"#{param}\" not found on message with address \"#{@address}\""
		return val

	# ## `addBus()`
	# Adds a bus to the internal list.
	addBus: (bus) ->
		return @ if @sawBus(bus)
		@_busses.push bus.id
		return @

	# ## `sawBus()`
	# Returns true if this message has been processed by the supplied bus.
	sawBus: (bus) ->
		return _.contains @_busses, bus.id

	# ## `toJSON()`
	# Converts the message to a plain JSON object for possible storage or transmission.
	toJSON: ->
		json =
			calamity: C.version
			address: @address
			data: @data
			status: @status
			error: @error
		if @_replyHandler?
			json.reply = _.bind @reply, @
		return json

	# ## `fromJSON()`
	# Converts a JSON object to an EventMessage.
	# The message must have been serialized using `EventMessage`'s own `toJSON()` method, otherwise weird things could happen.
	@fromJSON = (json) ->
		throw new Error "JSON must be an object" unless _.isObject json
		throw new Error "Serialized JSON is not for calamity: #{JSON.stringify(json)}" unless json.calamity?
		msg = new EventMessage json.address, json.data, json.reply
		msg.status = json.status
		msg.error = json.error
		return msg
