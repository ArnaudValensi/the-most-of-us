function new_sprite_comp(options)
  local frame_count = 0
  local current_sprite = 1

  return {
    name = "sprite",
    sprites = options.sprites,
    time_per_sprite = options.time_per_sprite or 15,
    width_in_cell = options.width_in_cell or 1,
    height_in_cell = options.height_in_cell or 1,

    init = function(self)
      self.position = self.game_object:get_component("transform").position
    end,

    update = function(self)
      if self.time_per_sprite == frame_count then
        current_sprite = current_sprite % #self.sprites + 1
        frame_count = 0
      else
        frame_count += 1
      end
    end,

    draw = function(self)
      spr(
        self.sprites[current_sprite],
        self.position.x,
        self.position.y,
        self.width_in_cell,
        self.height_in_cell
      )
    end,
  }
end
