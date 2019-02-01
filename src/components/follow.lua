function new_follow_comp(options)
  return {
    name = "follow",
    target = options.target,
    smooth_speed = options.smooth_speed or 0.2,

    init = function(self)
      self.target_transform = self.target:get_component("transform")
      self.transform = self.game_object:get_component("transform")
    end,

    update = function(self)
      local target_position = self.target_transform:get_center_position()
      camera(
        target_position.x - 64,
        target_position.y - 64
      )
    end,
  }
end
