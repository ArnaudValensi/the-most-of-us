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
