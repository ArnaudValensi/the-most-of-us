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
    end,

    draw = function(self)
      camera(
        self.position.x - 64,
        self.position.y - 64
      )
    end,
  }
end
function new_player_comp(speed)
  speed = speed or 1
  return {
    name = "player",

    init = function(self)
      self.position = self.game_object:get_component("transform").position
      self.sprite = self.game_object:get_component("sprite")
    end,

    update = function(self)
      local move_left = btn(0)
      local move_right = btn(1)
      local move_up = btn(2)
      local move_down = btn(3)

      if move_left then
        self.position.x -= speed
        self.sprite:flip(true)
      end
      if move_right then
        self.position.x += speed
        self.sprite:flip(false)
      end
      if move_up then self.position.y -= speed end
      if move_down then self.position.y += speed end

      if (move_left or move_right or move_up or move_down) then
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
function new_transform_comp(x, y)
  return {
    name = "transform",
    position = new_vec(x, y),
  }
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

        init = function()
            for component in all(components) do
                if component.init then
                    component:init()
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
      str=str..tostring(k).."->"..tostring(v).." "
    end
    return str.."}"
  end
  return "unkown" -- should never show
end
function new_vec(x, y)
    return {
        x = x,
        y = y,
    }
end
gameobjects = require_game_objects()

local player = gameobjects:new("player")
player:add_component(new_transform_comp(1 * 8, 0))
player:add_component(new_sprite_comp({
  animations = {
    ["idle"] = {64} ,
    ["walk"] = {64, 65},
  },
  default = "idle",
}))
player:add_component(new_player_comp(3))

local cam = gameobjects:new("camera")
cam:add_component(new_transform_comp(0, 0))
cam:add_component(new_follow_comp({ target = player }))

function _init()
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

__gfx__
0000000066666667d666666d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000166666776dddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000116667776dddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111177776dddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111117776dddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000111555776dddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000115555576dddddd500000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000015555555d555555100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
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
__map__
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0202020202020202020202020202020202020202020202020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__sfx__
__music__