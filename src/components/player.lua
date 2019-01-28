function new_player_comp(speed)
  speed = speed or 1
  return {
    name = "player",
    update = function(self)
      local position = self.game_object:get_component("transform").position

      if (btn(0)) then position.x -= speed end
      if (btn(1)) then position.x += speed end
      if (btn(2)) then position.y -= speed end
      if (btn(3)) then position.y += speed end
    end,
  }
end
