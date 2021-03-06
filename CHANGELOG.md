# 0.0.7 / Unreleased

* Adds timestamps to actions
* Adds housekeeping
* Adds JS/CSS minification
* Adds New Relic and ping middleware
* Splits up index page for logged in and not logged in players
* Adds a fake random match if no public match exists yet
* Makes game resize
* Removes the bouncing when opening games
* Fixes jumping units bug
* Games now load without page reloads
* Fixes ending scenarios. State is now set correctly.
* Does not load ended games anymore
* Fixes win condition propagation on action arrival
* Limits public chat messages to 150
* Fixes unit movement highlights. Should now be always shown in the first place
* Improved the specs page
* Movement does not longer cost AP based on the travelled distance
* Adds some debugging information to check listed matches' IDs
* Makes default maps easier updatable by moving from CoffeeScript to vanilla JS
* Adds chat back in after it has been accidentially removed from the UI
* Fixes a problem with games with friends
* Removes "Ended Games" list
* Adds an option to forfeit a game
* Adds lobby chat again
* Shows images from chat messages
* Auto-links URLs in chat messages
* Adds in universal chat UI
* Fixes creation of matches with custom maps
* Adds links to forum and feedback
* Adds user voice widget
* Resolved game progress slider layout

# 0.0.6 / Unreleased

* Adds a shady workaround for the "Loading... shown forever" bug
* Lets ended games show up as "your turn" when you have not seen the result yet
* Adds ended games
* Always shows winning UI now if there is a winner already
* Fixes chat scrolling to bottom
* Retrieves player info in a better way
* Fixes points UI on game load
* Fixes not shown movement highlights for units sometimes when selecting them
* Prevents dropzone selection of other players
* Fixes player order in firebase
* Makes it possible to switch games again
* Fixes "first turn and nothing happens" bug
* hides the navigation until games do not longer require full reload
* shows warning when there are no public games of a certain pace

# 0.0.5 / 2013-07-18

* Removes Basic Auth
* Swaps the default maps to real ones
* Adds a chat
* Directly jumps into games when creating them
* Makes it possible to start public matches
* Preselects the first default map in the custom match creation screen
* Makes the pace UI real
* Splits list in matches where it's your turn and those where it's another player's turn
* Removes invites when matches become full
* Adds a link to directly log in when not logged in
* Fixes problems when loading games (all actions load properly)
* Prevents overlays etc when rewinding actions
* Prevents players from taking turns for other players
* Adds match action persistence
* makes matches rewindable
* queues animated text overlays
* animated text overlays
* improves unit selection
* fixed fly over queue bug
* improved path behaviour
* added fadeout bahviour
* Shows pop over when capturing a drop zone
* Fixes for streak bug
* Shows overlays on streak events
* Only shows streak UI after first attack
* Repositions labels on points UI to prevent overlaps
* Adds QS debug panel
* Turns off debugging panel
* Makes game playable when logged in only
* Fixes border rendering for small maps
* Prohibits newly created units to move
* Renders maps the same as in the map editor
* Makes custom maps loadable
* Centers map nicely
* Improves sizing, adds border
* Adds streaks
* Makes games winable
* Adds points for attacks and captures
* Adds drop zones
* Adds support for new map format and updated units
* Adds AP
* Lets units become mortal
* Adds fights
* Adds unit movement along paths
* Adds unit movement
* Adds rule sets
* Adds turns to the game
* Adds an offset to the units
* Adds new terrain assets from mapEdit

# 0.0.4 / 2013-06-05

* Units can be moved
* Imports units and displays them
* Refactors map rendering and scrolling
* Adds scrolling
* Makes sample maps work

# 0.0.3 / 2013-05-29

* Moves to a threaded Thin server
* Adds asset pre-compilation
* Adds CAAT and show a simple splash screen
* Adds Thin as a dependency for Heroku
* Fixes bug in config.ru

# 0.0.2 / 2013-05-29

* Adds HTTP basic auth for heroku deployment

# 0.0.1 / 2013-05-29

* The beginning