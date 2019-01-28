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
