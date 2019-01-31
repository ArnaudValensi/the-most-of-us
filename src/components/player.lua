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
