gameobjects = require_game_objects()

local player = gameobjects:new("player")
player:add_component(new_transform_comp(1 * 8, 0, 8, 8))
player:add_component(new_sprite_comp({
  animations = {
    ["idle"] = {64} ,
    ["walk"] = {64, 65},
  },
  default = "idle",
}))
player:add_component(new_player_comp(3))
player:add_component(new_line_of_sight_comp())

local cam = gameobjects:new("camera")
cam:add_component(new_transform_comp(0, 0))
cam:add_component(new_follow_comp({ target = player }))

function _init()
  printh('', 'log', true);
  gameobjects:init()
end

function _update()
  gameobjects:update()
end

function _draw()
  cls()
  map(0, 0, 0, 0, 128, 128)
  gameobjects:draw()
end
