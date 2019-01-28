-- change_state = require_change_state()
-- start_state = require_start_state()
gameobjects = require_game_objects()

-- state = start_state

function new_transform_comp(x, y)
  return {
    name = "transform",
    position = new_vec(x, y),
  }
end

function new_sprite_comp(options)
  return {
    name = "sprite",
    sprite_number = options.sprite_number,
    width_in_cell = options.width_in_cell or 1,
    height_in_cell = options.height_in_cell or 1,
    draw = function(self)
      local transform = self.game_object:get_component("transform")
      spr(
        self.sprite_number,
        transform.position.x,
        transform.position.y,
        self.width_in_cell,
        self.height_in_cell
      )
    end,
  }
end

local player = gameobjects:new("player")
player:add_component(new_transform_comp(1 * 8, 0))
player:add_component(new_sprite_comp({ sprite_number = 1 }))

function _init()
  printh('\n== init ==', 'log', true)
  -- state.on_start()
end

function _update()
  gameobjects:update()
  -- state.update()
end

function _draw()
  cls()
  gameobjects:draw()
  -- state.draw()
end
