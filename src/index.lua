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
wall:add_component(new_wall_comp(player))
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
  draw_selected_wall()
end

function draw_selected_wall()
  for wall in all(g_walls) do
    -- Draw wall.
    line(wall.start.x, wall.start.y, wall.stop.x, wall.stop.y, 8)
    -- Draw normal.
    line(
      wall.start.x + (wall.stop.x - wall.start.x) / 2,
      wall.start.y + (wall.stop.y - wall.start.y) / 2,
      wall.start.x + (wall.stop.x - wall.start.x) / 2 + wall.normal.x,
      wall.start.y + (wall.stop.y - wall.start.y) / 2 + wall.normal.y,
      7
    )
  end
end
