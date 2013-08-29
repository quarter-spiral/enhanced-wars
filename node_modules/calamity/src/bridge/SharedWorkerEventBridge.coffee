# Attaches an EvnetBus to another bus running inside a SharedWorker.
SharedWorkerEventBridge = class C.SharedWorkerEventBridge extends EventBridge
	# Returns true if shared workers are supported.
	supported: ->
		return !!window.SharedWorker

	# Instantiates a SharedWorker event bus.
	# The URL of the shared worker script must be provided.
	attach: (url) ->
		# Check for support.
		return if not @supported()
		# Instantiate SharedWorker.
		@worker = new SharedWorker(url);
		# Attach events on worker @todo
