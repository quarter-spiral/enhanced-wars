var ports = [];

// Connection handler
self.addEventListener("connect", function (event) {
	// Import port
	var port = event.ports[0];
	sendMessage("New connection, " + (ports.length+1) + " active");
	ports.push(port);

	// Message handler
	port.addEventListener("message", function (event) {
		sendMessage("Message received: " + event.data);
	});
	// Start port
	port.start();
});

// Sends a message to all connections
function sendMessage(message) {
	for (var i=0 ; i<ports.length ; i++) {
		ports[i].postMessage(message);
	}
}
