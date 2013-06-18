/*
 *= require ./lib/loader.js
 *= require ./vendor.js
 *= require ./lib.js
 *= require ./tool.js
 *= require ./logic.js
 *= require ./renderer.js
 */

require('radio')('ew/loader/done').broadcast();

var $ = require('jquery');
$(function() {
  var Game = require('Game');
  window.game = new Game();
});