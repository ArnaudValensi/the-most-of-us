function new_player_comp(speed)
  speed = speed or 1
  return {
    name = "player",

    init = function(self)
      self.position = self.game_object:get_component("transform").position
      self.sprite = self.game_object:get_component("sprite")
    end,

    update = function(self)
      if (btn(0)) then
        self.position.x -= speed
        self.sprite:set_direction_left(true)
      end
      if (btn(1)) then
        self.position.x += speed
        self.sprite:set_direction_left(false)
      end
      if (btn(2)) then self.position.y -= speed end
      if (btn(3)) then self.position.y += speed end
    end,
  }
end
