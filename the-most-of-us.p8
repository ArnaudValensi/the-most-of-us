pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
function new_player_comp(speed)
  speed = speed or 1
  return {
    name = "player",

    init = function(self)
      self.position = self.game_object:get_component("transform").position
    end,

    update = function(self)
      if (btn(0)) then self.position.x -= speed end
      if (btn(1)) then self.position.x += speed end
      if (btn(2)) then self.position.y -= speed end
      if (btn(3)) then self.position.y += speed end
    end,
  }
end
function new_sprite_comp(options)
  return {
    name = "sprite",
    sprite_number = options.sprite_number,
    width_in_cell = options.width_in_cell or 1,
    height_in_cell = options.height_in_cell or 1,

    init = function(self)
      self.position = self.game_object:get_component("transform").position
    end,

    draw = function(self)
      spr(
        self.sprite_number,
        self.position.x,
        self.position.y,
        self.width_in_cell,
        self.height_in_cell
      )
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
function new_vec(x, y)
    return {
        x = x,
        y = y,
    }
end
gameobjects = require_game_objects()

local player = gameobjects:new("player")
player:add_component(new_transform_comp(1 * 8, 0))
player:add_component(new_sprite_comp({ sprite_number = 1 }))
player:add_component(new_player_comp(3))

function _init()
  printh('\n== init ==', 'log', true)
  gameobjects:init()
end

function _update()
  gameobjects:update()
end

function _draw()
  cls()
  gameobjects:draw()
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

__gff__
__map__
__sfx__
__music__