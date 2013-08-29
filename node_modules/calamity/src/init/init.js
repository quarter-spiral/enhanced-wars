// Import underscore if necessary.
if (typeof _ === "undefined" && typeof require === "function") {
	_ = require("underscore");
}

// Init Calamity object.
var C = {version: "<%= pkg.version %>"};

var root = this
// CommonJS
if (typeof exports !== "undefined") {
	if (typeof module !== "undefined" && module.exports) {
		exports = module.exports = C;
	}
	exports.C = C;
}
// AMD
else if (typeof define === "function" && define.amd) {
    define(['calamity'], C);
}
// Browser
else {
	root['Calamity'] = C;
}
