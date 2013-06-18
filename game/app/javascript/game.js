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

function gup(name) {
  name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
  var regexS = "[\\?&]"+name+"=([^&#]*)";
  var regex = new RegExp( regexS );
  var results = regex.exec( window.location.href );
  if( results == null )
    return "";
  else
    return results[1].replace(/\/$/, '');
}
var mapToLoad = gup('m');

$(function() {
  var Game = require('Game');
  window.game = new Game({map: mapToLoad});
});