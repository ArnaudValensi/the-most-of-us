function new_sprite_comp(options)
  return {
    name = "sprite",
    sprite_number = options.sprite_number,
    width_in_cell = options.width_in_cell or 1,
    height_in_cell = options.height_in_cell or 1,
    draw = function(self)
      local transform = self.game_object:get_component("transform")
      spr(
        self.sprite_number,
        transform.position.x,
        transform.position.y,
        self.width_in_cell,
        self.height_in_cell
      )
    end,
  }
end
