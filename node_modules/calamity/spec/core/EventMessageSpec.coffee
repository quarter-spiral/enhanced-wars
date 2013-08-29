{EventBus, EventMessage} = require "../../../calamity"
sinon = require "sinon"

describe "EventMessage", ->

	it "should be empty when created", ->
		msg = new EventMessage
		expect(msg instanceof EventMessage).toBe true

	it "should create a message with correct address and data", ->
		msg = new EventMessage "address", "data"
		expect(msg.address).toBe "address"
		expect(msg.data).toBe "data"

	it "should remember if it has seen a bus or not", ->
		msg = new EventMessage
		bus = new EventBus
		expect(msg.sawBus bus).toBe false
		msg.addBus bus
		expect(msg.sawBus bus).toBe true
		expect(msg.sawBus new EventBus).toBe false

	describe "replies", ->
		message = null
		reply = null
		beforeEach ->
			reply = sinon.spy()
			message = new EventMessage "address", data:"foo", reply

		it "should call reply handler when replied", ->
			message.reply()
			waitsFor (-> reply.called), "Reply never called", 100
			runs ->
				expect(reply.callCount).toBe 1

		it "should be provided with a successful EventMessage by default", ->
			message.reply foo:"foo"
			waitsFor (-> reply.called), "Reply never called", 100
			runs ->
				replyMsg = reply.args[0][0]
				expect(replyMsg instanceof EventMessage).toBe true
				expect(replyMsg.data.foo).toBe "foo"
				expect(replyMsg.status).toBe "ok"
				expect(replyMsg.error).toBe null
				expect(replyMsg.isSuccess()).toBe true
				expect(replyMsg.isError()).toBe false

		it "should handle error replies", ->
			try
				throw new Error "Foo"
			catch error then message.replyError error, foo:"foo"
			waitsFor (-> reply.called), "Reply never called", 100
			runs ->
				expect(reply.callCount).toBe 1
				call = reply.getCall 0
				replyMsg = call.args[0]
				expect(replyMsg instanceof EventMessage).toBe true
				expect(replyMsg.status).toBe "error"
				#expect(replyMsg.error).toBe "Error: Foo"
				expect(replyMsg.data.message).toBe "Foo"
				expect(replyMsg.data.name).toBe "Error"
				expect(replyMsg.data.foo).toBe "foo"
				expect(replyMsg.isSuccess()).toBe false
				expect(replyMsg.isError()).toBe true

	describe "serialization", ->
		msg = null
		address = "address"
		data =
			a: "foo"
			b: -56.3
			c: false
			d: NaN
			e: Infinity
			f: {x:6, y:0}
		dataString = JSON.stringify data
		reply = null

		beforeEach ->
			reply = sinon.spy()
			msg = new EventMessage address, data, reply

		it "should convert to JSON", ->
			json = msg.toJSON()
			expect(json.calamity?).toBe true
			expect(json.address).toBe address
			expect(json.status).toBe "ok"
			expect(json.error).toBe null
			expect(typeof json.reply).toBe "function"
			expect(JSON.stringify(json.data)).toBe dataString

			# Replying should still work.
			json = msg.toJSON()
			json.reply.call @, foo:"foo"
			waitsFor (-> reply.called), "Reply never called", 100
			runs ->
				expect(reply.callCount).toBe 1
				call = reply.getCall 0
				expect(call.args[0] instanceof EventMessage).toBe true
				expect(call.args[0].data.foo).toBe "foo"

		it "should not add a reply in the JSON if there is not reply handler", ->
			msg = new EventMessage address, data
			json = msg.toJSON()
			expect(json.reply).toBe undefined

		it "should deserialize from JSON", ->
			json = msg.toJSON()
			dmsg = EventMessage.fromJSON json
			expect(typeof dmsg).toBe "object"
			expect(dmsg).not.toBe msg
			expect(dmsg instanceof EventMessage).toBe true
			expect(dmsg.address).toBe address
			expect(dmsg.status).toBe "ok"
			expect(dmsg.error).toBe null
			expect(JSON.stringify(dmsg.data)).toBe dataString

			# Replying should work like before.
			dmsg.reply foo:"foo"
			waitsFor (-> reply.called), "Reply never called", 100
			runs ->
				expect(reply.callCount).toBe 1
				call = reply.getCall 0
				expect(call.args[0] instanceof EventMessage).toBe true
				expect(call.args[0].data.foo).toBe "foo"

	describe "variables", ->
		data =
			foo: "a"
			bar: "b"
		msg = null
		beforeEach ->
			msg = new EventMessage "address", data

		it "should return optional values", ->
			expect(msg.getOptional "foo").toBe "a"
			expect(msg.getOptional "bar").toBe "b"
			expect(msg.getOptional "bar", "default").toBe "b"
			expect(msg.getOptional "doesntexist").toBe undefined
			expect(msg.getOptional "doesntexist", "default").toBe "default"

		it "should return required values", ->
			expect(msg.getRequired "foo").toBe "a"
			expect(msg.getRequired "bar").toBe "b"

		it "should throw errors on missing required values without a reply handler", ->
			check = ->
				msg.getRequired "doesntexist"
			expect(check).toThrow "Variable \"doesntexist\" not found on message with address \"address\""

		it "should return deep values", ->
			msg = new EventMessage "address",
				foo:
					bar: "abc"
			expect(msg.getOptional "foo.bar").toBe "abc"
			expect(msg.getOptional "foo.a").toBe undefined
			expect(msg.getRequired "foo.bar").toBe "abc"
			test = -> msg.getRequired "foo.a"
			expect(test).toThrow "Variable \"foo.a\" not found on message with address \"address\""

		it "should support an empty dataset", ->
			msg = new EventMessage "address", null
			expect(msg.getOptional "nope").toBe undefined
			test = ->
				msg.getRequired "nope"
			expect(test).toThrow("Variable \"nope\" not found on message with address \"address\"")


	# Planned feature.
	describe "error proxy", ->
		msg = null
		msgNoReply = null
		errorMsg = null
		replier = null
		handler = null
		beforeEach ->
			replier = sinon.spy()
			handler = sinon.spy()
			msg = new EventMessage "address", null, replier
			msgNoReply = new EventMessage "address"
			errorMsg = new EventMessage
			errorMsg.status = "error"
			errorMsg.error = "Error"

		it "should pass the call onto handler if nothing is wrong", ->
			# Without first arg.
			msg.catch handler
			expect(handler.callCount).toBe 1
			# With first arg.
			msg.catch null, handler
			expect(handler.callCount).toBe 2
			msg.catch undefined, handler
			expect(handler.callCount).toBe 3
			msg.catch msg, handler
			expect(handler.callCount).toBe 4

			# Without first arg.
			msgNoReply.catch handler
			expect(handler.callCount).toBe 5
			# With first arg.
			msgNoReply.catch null, handler
			expect(handler.callCount).toBe 6
			msgNoReply.catch undefined, handler
			expect(handler.callCount).toBe 7
			msgNoReply.catch msg, handler
			expect(handler.callCount).toBe 8

			expect(replier.callCount).toBe 0

		it "should propagate message errors unless it has a reply handler", ->
			# reply has an error:
			# msg.catch reply, =>
			# No reply should throw the exception directly.
			testNoReply = -> msgNoReply.catch errorMsg, handler
			expect(testNoReply).toThrow "Error"
			expect(handler.callCount).toBe 0
			# With reply handler should pass the error along.
			msg.catch errorMsg, handler
			waitsFor (-> replier.called), "Replier never called", 100
			runs ->
				expect(replier.callCount).toBe 1
				expect(handler.callCount).toBe 0
				reply = replier.getCall(0).args[0]
				expect(reply).toBe errorMsg

		it "should propagate real errors unless it has a reply handler", ->
			# reply *is* an error:
			# msg.catch reply, =>
			error = new Error "Error"
			# No reply should throw the exception directly.
			testNoReply = -> msgNoReply.catch error, handler
			expect(testNoReply).toThrow "Error"
			expect(handler.callCount).toBe 0
			# With reply handler should pass the error along.
			msg.catch error, handler
			waitsFor (-> replier.called), "Replier never called", 100
			runs ->
				expect(replier.callCount).toBe 1
				expect(handler.callCount).toBe 0
				reply = replier.getCall(0).args[0]
				expect(reply.status).toBe "error"
				expect(reply.error.split("\n")[0]).toBe "Error: Error :: Error: Error"

		it "should propagate thrown errors unless it has a reply handler", ->
			# Supplied handler threw an error:
			# msg.catch (reply) =>
			handler = sinon.spy -> throw new Error "Error"
			# No reply should throw the exception directly.
			testNoReply = -> msgNoReply.catch handler
			expect(testNoReply).toThrow "Error"
			expect(handler.callCount).toBe 1
			# With reply handler should pass the error along.
			msg.catch handler
			waitsFor (-> replier.called), "Replier never called", 100
			runs ->
				expect(replier.callCount).toBe 1
				expect(handler.callCount).toBe 2
				reply = replier.getCall(0).args[0]
				expect(reply.status).toBe "error"
				expect(reply.error.split("\n")[0]).toBe "Error: Error :: Error: Error"
