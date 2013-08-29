# # EmitterMixin
# Mixin class for attaching an instance-local EventBus to objects.
# It adds the `on()`, `off()`, and `_trigger()` methods to the object.
EmitterMixin = class C.EmitterMixin
	# ## `on()`
	# Register a handler to an address.
	on: (address, handler, context) ->
		context or= @
		return getEmitterBus(@).subscribe(address, handler, context)

	# ## `off()`
	# Unregisters a handler from an address.
	off: (address, handler, context) ->
		return unless hasEmitterBus(@)
		context or= @
		return getEmitterBus(@).unsubscribe(address, handler, context)

	# ## `_trigger()`
	# Publishes an event to an address.
	trigger: (address, data, reply) ->
		return unless hasEmitterBus(@)
		return getEmitterBus(@).publish(address, data, reply)

# Private statis function for checking is the object has an emitter bus.
hasEmitterBus = (obj) ->
	return false unless obj._calamity
	return false unless obj._calamity.emitter
	return false unless obj._calamity.emitter.bus
	return true

# Private static function for preparing an on-demand event bus for an object.
getEmitterBus = (obj) ->
	calamity = (obj._calamity or= {})
	emitter = (calamity.emitter or= {})
	return emitter.bus or= new EventBus()


# ## `Calamity.emitter()`
# Adds emitter functionality.
C.emitter = (obj) ->
	_.extend obj, EmitterMixin.prototype
