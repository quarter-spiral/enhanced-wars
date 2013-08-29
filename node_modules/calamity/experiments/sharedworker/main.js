$(function(){

	if (!window.SharedWorker) {
		throw new Error("SharedWorker not supported");
	}
	var $log = $("textarea");
	function log(msg) {
		$log.html($log.html() + msg + "\n");
	}

	// Create worker
	var worker = window.worker = new SharedWorker("worker.js", "main");
	worker.addEventListener("error", function() {
		console.log("SharedWorker error:", arguments);
	});
	worker.port.addEventListener("message", function(message) {
		var data = message.data;
		log (">> " + data);
	});
	worker.port.start();
	console.log("SharedWorker started:", worker);

	// Send message button
	$("button").click(function() {
		worker.port.postMessage("This is a message");
	});
});
