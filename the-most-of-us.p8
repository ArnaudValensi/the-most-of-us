pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function require_change_state()
    local function change_state(to_state, options)
    cls()
    state.on_stop()
    state = to_state
    to_state.on_start(options)
    to_state.update()
  end

  return change_state
end
function require_game_objects()
    local objects = {}
    local components = {}
    local next_id = 0

    local game_objects = {
        new = function(name)
            new_game_object = {
                id = next_id,
                name = name,
                add_component = function(self, component)
                    component.game_object = self
                end
            }

            next_id += 1
            objects[name] = new_game_object

            return new_game_object
        end,

        update = function()
            for component in all(components) do
                component:update()
            end
        end
    }

    return game_objects
end
function require_start_state()
    local start_state = {
        on_start = function()
            printh('hello', 'log');
        end,

        on_stop = function()

        end,

        update = function()

        end,

        draw = function()

        end
    }

    return start_state
end
function new_vec(x, y)
    return {
        x = x,
        y = y,
    }
end
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

__gfx__
00000000666666670000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000166666770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000116667770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111177770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111117770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111555770000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000115555570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000155555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
