gameobjects = require_game_objects()

local player = gameobjects:new("player")
player:add_component(new_transform_comp(1 * 8, 0))
player:add_component(new_sprite_comp({ sprite_number = 1 }))
player:add_component(new_player_comp(3))

function _init()
  printh('\n== init ==', 'log', true)
end

function _update()
  gameobjects:update()
end

function _draw()
  cls()
  gameobjects:draw()
end
