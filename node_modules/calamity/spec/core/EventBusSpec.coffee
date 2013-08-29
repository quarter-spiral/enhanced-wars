C = require "../../../calamity"
sinon = require "sinon"

describe "EventBus", ->
	bus = null

	beforeEach ->
		bus = new C.EventBus()

	it "should route messages to correct handlers", ->
		handler11 = sinon.spy()
		handler12 = sinon.spy()
		handler2 = sinon.spy()
		bus.subscribe "address/1", handler11
		bus.subscribe "address/1", handler12
		bus.subscribe "address/2", handler2

		runs ->
			bus.publish "address/1"
		waits 10 # @todo use waitsFor
		runs ->
			expect(handler11.callCount).toBe 1
			expect(handler12.callCount).toBe 1
			expect(handler2.called).toBe false

			bus.publish "address/2"
		waits 10 # @todo use waitsFor
		runs ->
			expect(handler11.callCount).toBe 1
			expect(handler12.callCount).toBe 1
			expect(handler2.called).toBe true

	it "should send correct message to handlers", ->
		msg = null
		handler = (m) ->
			msg = m
		bus.subscribe "address", handler
		runs ->
			bus.publish "address", "data"
		waits 10 # @todo use waitsFor
		runs ->
			expect(msg.address).toBe("address")
			expect(msg.data).toBe("data")

	it "should send commands to a single handler only", ->
		handler1 = sinon.spy()
		handler2 = sinon.spy()
		bus.subscribe "address", handler1
		bus.subscribe "address", handler2

		runs ->
			bus.send "address"
		waitsFor (-> handler1.called or handler2.called), "Neither handler called", 100
		runs ->
			if handler1.called
				expect(handler1.callCount).toBe 1
				expect(handler2.callCount).toBe 0
			if handler2.called
				expect(handler1.callCount).toBe 0
				expect(handler2.callCount).toBe 1
			expect(handler1.callCount + handler2.callCount).toBe 1
