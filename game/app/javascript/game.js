/*
 *= require ./vendor.js
 *= require ./lib.js
 *= require ./logic.js
 *= require ./renderer.js
 */

domready(function() {
  window.game = new require('Game')();
})
