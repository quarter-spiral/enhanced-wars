# # MemoryEventBridge
# `EventBridge` implementation which ties to `EventBus` instances together directly in memory.
MemoryEventBridge = class C.MemoryEventBridge extends EventBridge
	# ## `handler()`
	# Repeating handler implementation.
	handler: (msg) ->
#		console.log msg.serialize() + "\n\n"
		# Pass msg onto all connected busses
		for bus in @_busses
			bus.publish msg
		return
