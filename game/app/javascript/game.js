/*
 *= require ./lib/loader.js
 *= require ./vendor.js
 *= require ./lib.js
 *= require ./logic.js
 *= require ./renderer.js
 */

require('domReady')(function() {
  window.game = new require('Game')();
})
