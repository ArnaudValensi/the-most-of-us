function new_line_of_sight_comp()
  local view_radius = 64
  local view_angle = 90

  function dir_from_angle(angle)
    local turns = angle / 360

    return new_vec(
      -sin(turns),
      -cos(turns)
    )
  end

  return {
    name = "line_of_sight",

    init = function(self)
      self.transform = self.game_object:get_component("transform")
    end,

    draw = function(self)
      -- cls()
      local position = self.transform:get_center_position()
      circ(position.x, position.y, view_radius, 8)

      for i = 0, view_angle do
        local direction1 = dir_from_angle(-i / 2)
        local direction2 = dir_from_angle(i / 2)

        local sight_line1 = direction1:scalar_mul(view_radius)
        local sight_line2 = direction2:scalar_mul(view_radius)

        local target_point1 = position:add(sight_line1)
        local target_point2 = position:add(sight_line2)

        -- printh('---', 'log');
        -- printh('position: '..position:to_string(), 'log');
        -- printh('direction1: '..direction1:to_string(), 'log');
        -- printh('direction2: '..direction2:to_string(), 'log');
        -- printh('sight_line1: '..sight_line1:to_string(), 'log');
        -- printh('sight_line2: '..sight_line2:to_string(), 'log');
        -- printh('target_point1: '..target_point1:to_string(), 'log');
        -- printh('target_point2: '..target_point2:to_string(), 'log');

        line(position.x, position.y, target_point1.x, target_point1.y, 7)
        line(position.x, position.y, target_point2.x, target_point2.y, 7)
      end

      local mask = {}
      local str = ''
      for y = 0, 127 do
        mask[y + 1] = {}
        str = str..'\n'
        for x = 0, 127 do
          mask[y + 1][x + 1] = pget(x, y)
          str = str..pget(x, y)
        end
      end

      -- printh(str, 'log');
    end,
  }
end
