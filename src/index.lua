gameobjects = require_game_objects()
g_walls = {}

local player = gameobjects:new("player")
player:add_component(new_transform_comp(10 * 8, 10 * 8, 8, 8))
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

local wall = gameobjects:new("wall1")
wall:add_component(new_transform_comp(8 * 8, 9 * 8, 8, 8))
wall:add_component(new_wall_comp())
wall:add_component(new_sprite_comp({
  animations = { ["idle"] = {4} },
  default = "idle",
}))

function _init()
  printh('', 'log', true);
  gameobjects:init()
  gameobjects:late_init()
end

function _update()
  g_walls = {}
  gameobjects:update()
end

function _draw()
  cls()
  map(0, 0, 0, 0, 128, 128)
  gameobjects:draw()
  gameobjects:late_draw()
end
