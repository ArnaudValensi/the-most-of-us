pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function new_follow_comp(options)
  return {
    name = "follow",
    target = options.target,
    smooth_speed = options.smooth_speed or 0.2,

    init = function(self)
      self.target_position = self.target:get_component("transform").position
      self.position = self.game_object:get_component("transform").position
    end,

    update = function(self)
      local position = self.position
      position.x = lerp(position.x, self.target_position.x, self.smooth_speed)
      position.y = lerp(position.y, self.target_position.y, self.smooth_speed)

      camera(
        self.position.x - 64,
        self.position.y - 64
      )
    end,
  }
end
function new_line_of_sight_comp(segments)
  function round(x)
    return flr(x+0.5)
  end

  function find_polygon_edges(point_a, point_b, left_points, right_points)
    local ax, ay = point_a.x, round(point_a.y)
    local bx, by = point_b.x, round(point_b.y)

    if (ay == by) return

    local x = ax
    local x_distance_at_each_increment = (bx - ax) / abs(by - ay)
    local step = 1

    if by < ay then
     -- switch direction and tables
     right_points, step = left_points, -1
    end
    for y = ay, by, step do
     right_points[y] = x
     x += x_distance_at_each_increment
    end
  end

  function draw_polygon(points)
    local left_points, right_points, nb_points = {}, {}, #points
    -- update left_points and right_points using each edge in turn
    for i = 1, nb_points do
     find_polygon_edges(
      points[i],
      points[i % nb_points + 1],
      left_points,
      right_points
     )
    end
    -- use the tables to draw each horizontal line
    for y, left_point in pairs(left_points) do
      local right_point = right_points[y]
      line(left_point, y, right_point, y)
    end
  end

  function get_value_side(value, light_range)
    local threshold = light_range - 0.01
    if (value > threshold) return 1
    if (value < -threshold) return -1
    return 0
  end

  function get_side_index(pos, light_range)
    local x = get_value_side(pos.x, light_range)
    local y = get_value_side(pos.y, light_range)
    local side_index = 0

    if (x == -1) side_index += 1 --left
    if (y == -1) side_index += 2 --top
    if (x == 1) side_index += 4 --right
    if (y == 1) side_index += 8 --bottom

    return side_index
  end

  function calculate_shadow_volume(light_pos, light_range, wall)
    -- Wall endpoints
    local start, stop = wall.start, wall.stop
    -- Calculate light rays towards start and stop
    local dist_light_to_start, dist_light_to_stop = start - light_pos, stop - light_pos
    -- Extend the rays until they intersect with the
    -- nearest boundary defined by light range
    -- (white points)
    local cs = light_range / max(abs(dist_light_to_start.x), abs(dist_light_to_start.y))
    local ce = light_range / max(abs(dist_light_to_stop.x), abs(dist_light_to_stop.y))
    local projection_start = light_pos + dist_light_to_start * cs
    local projection_stop = light_pos + dist_light_to_stop * ce

    local dist_light_to_proj_start = projection_start - light_pos
    local dist_light_to_proj_stop = projection_stop - light_pos

    printh('dist_light_to_proj_start(): '..dist_light_to_proj_start());
    printh('dist_light_to_proj_stop(): '..dist_light_to_proj_stop());

    local start_side_index = get_side_index(dist_light_to_proj_start, light_range)
    local stop_side_index = get_side_index(dist_light_to_proj_stop, light_range)
    local sides = start_side_index + stop_side_index
    -- local sides = bor(start_side_index, stop_side_index)

    printh('start_side_index: '..start_side_index);
    printh('stop_side_index: '..stop_side_index);
    printh('sides: '..sides);

    local points = {
      projection_start,
      wall.start,
      wall.stop,
      projection_stop
    }

    -- if () return points

    if (sides == 3) then
      add(points, v(-light_range, -light_range) + light_pos)
    elseif (sides == 6) then
      add(points, v(light_range, -light_range) + light_pos)
    elseif (sides == 9) then
      add(points, v(-light_range, light_range) + light_pos)
    elseif (sides == 12) then
      add(points, v(light_range, light_range) + light_pos)
    elseif (sides == 5) then
      if (dist_light_to_proj_start.y < 0) then
        add(points, v(-light_range, -light_range) + light_pos)
        add(points, v(light_range, -light_range) + light_pos)
      else
        add(points, v(light_range, light_range) + light_pos)
        add(points, v(-light_range, light_range) + light_pos)
      end
    elseif (sides == 10) then
      if (dist_light_to_proj_start.x < 0) then
        add(points, v(-light_range, light_range) + light_pos)
        add(points, v(-light_range, -light_range) + light_pos)
      else
        add(points, v(light_range, -light_range) + light_pos)
        add(points, v(light_range, light_range) + light_pos)
      end
    end
    -- if (sides == 3) add(points, v(projection_stop.x, projection_start.y))


    return projection_start, projection_stop, points
  end

  function debug_shadow(wall, projection_start, projection_stop)
    -- printh('start | stop: '..projection_start()..' | '..projection_stop());
    circ(wall.stop.x, wall.stop.y, 2, 2) -- Red
    circ(projection_stop.x, projection_stop.y, 2, 2) -- Red
    circ(projection_start.x, projection_start.y, 2, 1) -- Blue
    circ(wall.start.x, wall.start.y, 2, 1) -- Blue
    line(wall.start.x, wall.start.y, projection_start.x, projection_start.y)
    line(wall.stop.x, wall.stop.y, projection_stop.x, projection_stop.y)
    line(wall.stop.x, wall.stop.y, wall.start.x, wall.start.y)
    line(wall.start.x, wall.start.y, wall.stop.x, wall.stop.y)
    line(projection_start.x, projection_start.y, projection_stop.x, projection_stop.y)
  end

  function compute_wall_shadow(light_pos, light_range, wall)
    local projection_start, projection_stop, points = calculate_shadow_volume(light_pos, light_range, wall)

    debug_shadow(wall, projection_start, projection_stop)

    draw_polygon(points)
  end

  return {
    name = "line_of_sight",

    init = function(self)
      self.transform = self.game_object:get_component("transform")
    end,

    late_init = function(self)
      self.segments = gameobjects:get_by_name("wall1"):get_component("wall"):get_segments()
    end,

    late_draw = function(self)
      -- Light position and range
      local light_pos = self.transform:get_center_position()
      local light_range = 50
      local wall = self.segments[3]

      compute_wall_shadow(light_pos, light_range, wall)
    end,
  }
end
function new_player_comp(speed)
  speed = speed or 1
  return {
    name = "player",

    init = function(self)
      self.transform = self.game_object:get_component("transform")
      self.sprite = self.game_object:get_component("sprite")
    end,

    update = function(self)
      local position = self.transform.position
      local size = self.transform.size
      local move_left = btn(0)
      local move_right = btn(1)
      local move_up = btn(2)
      local move_down = btn(3)
      local new_position = v(position.x, position.y)

      if move_left then
        new_position.x -= speed
        self.sprite:flip(true)
      end
      if move_right then
        new_position.x += speed
        self.sprite:flip(false)
      end
      if move_up then new_position.y -= speed end
      if move_down then new_position.y += speed end

      local want_move = new_position != position
      local has_moved = false

      if want_move and not is_transform_colliding_map_cell(new_position, size) then
        position.x = new_position.x
        position.y = new_position.y
        has_moved = true
      end

      if (has_moved) then
        self.sprite:set_animation("walk")
      else
        self.sprite:set_animation("idle")
      end
    end,
  }
end
function new_sprite_comp(options)
  local animations = options.animations
  local time_per_sprite = options.time_per_sprite or 15
  local width_in_cell = options.width_in_cell or 1
  local height_in_cell = options.height_in_cell or 1
  local frame_count = 0
  local current_sprite = 1
  local current_animation_name = nil
  local current_animation = animations[options.default]
  local flip = false

  return {
    name = "sprite",
    init = function(self)
      self.position = self.game_object:get_component("transform").position
    end,

    update = function(self)
      if time_per_sprite == frame_count then
        current_sprite = current_sprite % #current_animation + 1
        frame_count = 0
      else
        frame_count += 1
      end
    end,

    draw = function(self)
      spr(
        current_animation[current_sprite],
        self.position.x,
        self.position.y,
        width_in_cell,
        height_in_cell,
        flip
      )
    end,

    flip = function(self, is_left)
      flip = is_left
    end,

    set_animation = function(self, animation_name)
      if current_animation_name != animation_name then
        current_animation = animations[animation_name]
        current_animation_name = animation_name
        current_sprite = 1
      end
    end,
  }
end
function new_transform_comp(x, y, size_x, size_y)
  return {
    name = "transform",
    position = v(x, y),
    size = v(size_x or 0, size_y or 0),
    get_center_position = function(self)
      return v(
        self.position.x + self.size.x / 2,
        self.position.y + self.size.y / 2
      )
    end
  }
end
function new_wall_comp()
  local segments = {}

  return {
    name = "wall",

    init = function(self)
      local transform = self.game_object:get_component("transform")
      local position = transform.position
      local size = transform.size

      -- Top
      segments[1] = {
        start = v(position.x, position.y),
        stop = v(position.x + size.x - 1, position.y),
        normal = v(0, -1),
      }
      -- Right
      segments[2] = {
        start = v(position.x + size.x - 1, position.y),
        stop = v(position.x + size.x - 1, position.y + size.y - 1),
        normal = v(1, 0),
      }
      -- Bottom
      segments[3] = {
        start = v(position.x + size.x - 1, position.y + size.y - 1),
        stop = v(position.x, position.y + size.y - 1),
        normal = v(0, 1),
      }
      -- Left
      segments[4] = {
        start = v(position.x, position.y + size.y - 1),
        stop = v(position.x, position.y),
        normal = v(-1, 0),
      }
    end,

    late_draw = function(self)
      -- for segment in all(segments) do
      --   -- Draw segment.
      --   line(segment.start.x, segment.start.y, segment.stop.x, segment.stop.y, 8)
      --   -- Draw normal.
      --   line(
      --     segment.start.x + (segment.stop.x - segment.start.x) / 2,
      --     segment.start.y + (segment.stop.y - segment.start.y) / 2,
      --     segment.start.x + (segment.stop.x - segment.start.x) / 2 + segment.normal.x,
      --     segment.start.y + (segment.stop.y - segment.start.y) / 2 + segment.normal.y,
      --     7
      --   )
      -- end
    end,

    get_segments = function(self)
      return segments
    end
  }
end
function is_transform_colliding_map_cell(position, size)
  function is_vec_colliding_cell(vec)
    return fget(mget(vec.x / 8, vec.y / 8), 0)
  end

  local top_left = v(
    position.x,
    position.y
  )
  local top_right = v(
    position.x + size.x - 1,
    position.y
  )
  local bottom_right = v(
    position.x + size.x - 1,
    position.y + size.y - 1
  )
  local bottom_left = v(
    position.x,
    position.y + size.y - 1
  )

  return is_vec_colliding_cell(top_left)
   or is_vec_colliding_cell(top_right)
   or is_vec_colliding_cell(bottom_right)
   or is_vec_colliding_cell(bottom_left)
end
function require_game_objects()
    local objects = {}
    local components = {}
    local next_id = 0

    local game_objects = {
        new = function(self, name)
            local object_components = {}

            new_game_object = {
                id = next_id,
                name = name,
                add_component = function(self, component)
                    add(components, component)
                    object_components[component.name] = component
                    component.game_object = self
                end,
                get_component = function(self, name)
                    return object_components[name]
                end,
            }

            next_id += 1
            objects[name] = new_game_object

            return new_game_object
        end,

        get_by_name = function(self, name)
            return objects[name]
        end,

        init = function()
            for component in all(components) do
                if component.init then
                    component:init()
                end
            end
        end,

        late_init = function()
            for component in all(components) do
                if component.late_init then
                    component:late_init()
                end
            end
        end,

        update = function()
            for component in all(components) do
                if component.update then
                    component:update()
                end
            end
        end,

        draw = function()
            for component in all(components) do
                if component.draw then
                    component:draw()
                end
            end
        end,

        late_draw = function()
            for component in all(components) do
                if component.late_draw then
                    component:late_draw()
                end
            end
        end
    }

    return game_objects
end
function lerp(a, b, t)
  return a + (b - a) * t
end
function to_string(any)
  if type(any)=="function" then return "function" end
  if any==nil then return "nil" end
  if type(any)=="string" then return any end
  if type(any)=="boolean" then return any and "true" or "false" end
  if type(any)=="number" then return ""..any end
  if type(any)=="table" then -- recursion
    local str = "{ "
    for k,v in pairs(any) do
      str=str..to_string(k).."->"..to_string(v).." "
    end
    return str.."}"
  end
  return "unkown" -- should never show
end
vec={}
function vec:__add(v2)
 return v(self.x+v2.x,self.y+v2.y)
end
function vec:__sub(v2)
 return v(self.x-v2.x,self.y-v2.y)
end
function vec:__mul(a)
 return v(self.x*a,self.y*a)
end
function vec:__pow(v2)
 return self.x*v2.x+self.y*v2.y
end
function vec:__unm()
 return v(-self.x,-self.y)
end
function vec:__eq(v2)
  return self.x==v2.x and self.y==v2.y
 end
-- this is actually length-squared
-- easier to calculate, good enough
function vec:__len()
 return self.x*self.x+self.y*self.y
end
-- normalized vector
function vec:norm()
 return self*(1/sqrt(#self))
end
-- rotated 90-deg clockwise
function vec:rotcw()
 return v(-self.y,self.x)
end
-- force coordinates to
-- integers
function vec:ints()
 return v(flr(self.x),flr(self.y))
end
-- tostring method (uses __call
-- for token-saving, dirty,
-- i know)
function vec:__call()
 return self.x..', '..self.y
end
-- has to be there so
-- our metatable works
-- for both operators
-- and methods
vec.__index=vec

-- creates a new vector
function v(x,y)
 return setmetatable(
  {x=x,y=y},vec
 )
end
gameobjects = require_game_objects()

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
  gameobjects:update()
end

function _draw()
  cls()
  map(0, 0, 0, 0, 128, 128)
  gameobjects:draw()
  gameobjects:late_draw()
end

__gfx__
0000000066666667d666666dffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000166666776dddddd5ffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000116667776dddddd5ffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111177776dddddd5ffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111117776dddddd5ffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111555776dddddd5ffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000115555576dddddd5ffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015555555d5555551ffffffff444444440000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
090a0a00900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
900aaaa0090a0a000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
900a1a1a090aaaa04000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aaaaaaa09aa1a1a4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99a9aaa009a9aaaa4000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999aa009999aa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
99999900999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
90990900909900900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0303030303030303030303030303030303030303030303030303030303030303030303030303030303030000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
__music__