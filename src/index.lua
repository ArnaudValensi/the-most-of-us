change_state = require_change_state()
start_state = require_start_state()
gameobjects = require_game_objects()

state = start_state

function _init()
  state.on_start()
end

function _update()
  state.update()
end

function _draw()
  state.draw()
end
