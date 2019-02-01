gameobjects = require_game_objects()
g_walls = {}

function new_wall(player, x, y)
  local wall = gameobjects:new("wall1")
  wall:add_component(new_transform_comp(x * 8, y * 8, 8, 8))
  wall:add_component(new_wall_comp(player))
  wall:add_component(new_sprite_comp({
    animations = { ["idle"] = {4} },
    default = "idle",
  }))
end

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

new_wall(player, 8, 5)
new_wall(player, 8, 6)
new_wall(player, 8, 7)
new_wall(player, 8, 8)

new_wall(player, 10, 5)
new_wall(player, 10, 6)
new_wall(player, 10, 7)
new_wall(player, 10, 8)

new_wall(player, 6, 9)
new_wall(player, 7, 9)
new_wall(player, 8, 9)
new_wall(player, 6, 11)
new_wall(player, 6, 13)
new_wall(player, 6, 15)

new_wall(player, 10, 9)
new_wall(player, 11, 9)
new_wall(player, 12, 9)
new_wall(player, 12, 11)
new_wall(player, 12, 13)
new_wall(player, 12, 15)
new_wall(player, 12, 17)

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
  -- draw_selected_wall()
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
