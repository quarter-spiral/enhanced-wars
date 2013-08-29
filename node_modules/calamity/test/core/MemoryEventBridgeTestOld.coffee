calamity = require "../../../calamity"
async = require "async"

bus = null
bridge = null

next = null
n = null
msg = null
handler = null

exports.tests =
	setUp: (done) ->
		# Construct two event busses and connect then via a bridge.
		bus = [
			new calamity.EventBus()
			new calamity.EventBus()
		]
		bridge = new calamity.MemoryEventBridge()
			.connect(bus[0])
			.connect(bus[1])
		# Construct handlers and subscribe.
		next = () ->
			return
		# Reset base containers.
		n = []
		msg = []
		handler = []
		# For each bus.
		for a in [0..1]
			n.push []
			msg.push []
			handler.push []
			# For each address.
			for b in [0..1]
				n[a].push 0
				msg[a].push null
				do (a, b) ->
					# Create handler.
					h = (m) ->
						n[a][b]++
						msg[a][b] = m
						next()
					handler[a].push h
					# Subscribe handler.
					bus[a].subscribe "address"+b, h
		done()

	# Simple connection test.
	"simple connection": (test) ->
		#ßtest.done()
		#return
		test.expect 12
		async.series [
			# Publish on one bus.
			(callback) ->
				bus[0].publish "address0", "data0"
				_.delay callback, 10
			# Verify calls.
			(callback) ->
				test.equals 1, n[0][0]
				test.equals 0, n[0][1]
				test.equals 1, n[1][0]
				test.equals 0, n[1][1]
				test.equals "data0", msg[0][0].data
				test.equals "data0", msg[1][0].data
				callback()
			# Publish on the other bus.
			(callback) ->
				bus[1].publish "address1", "data1"
				_.delay callback, 10
			# Verify calls.
			(callback) ->
				test.equals 1, n[0][0]
				test.equals 1, n[0][1]
				test.equals 1, n[1][0]
				test.equals 1, n[1][1]
				test.equals "data1", msg[0][1].data
				test.equals "data1", msg[1][1].data
				callback()
				test.done()
		]
