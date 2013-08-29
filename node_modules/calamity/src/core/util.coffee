# # util
# A set of utilities used inside Calamity.

# Import Math functions.
random = Math.random
floor = Math.floor

# Hexadecimals.
HEX = "0123456789abcdef".split ""

# Generic utility functions.
util = C.util =
	# Generates a 128 bit ID.
	genId: ->
		id = ""
		for i in [1..32]
			id += HEX[floor(random() * HEX.length)]
		return id
