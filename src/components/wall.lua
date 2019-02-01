function new_wall_comp(player)
  local segments = {}

  return {
    name = "wall",

    init = function(self)
      local transform = self.game_object:get_component("transform")
      local position = transform.position
      local size = transform.size

      -- Top
      segments[1] = {
        start = v(position.x, position.y),
        stop = v(position.x + size.x - 1, position.y),
        normal = v(0, -1),
      }
      -- Right
      segments[2] = {
        start = v(position.x + size.x - 1, position.y),
        stop = v(position.x + size.x - 1, position.y + size.y - 1),
        normal = v(1, 0),
      }
      -- Bottom
      segments[3] = {

        start = v(position.x + size.x - 1, position.y + size.y - 1),
        stop = v(position.x, position.y + size.y - 1),
        normal = v(0, 1),
      }
      -- Left
      segments[4] = {
        start = v(position.x, position.y + size.y - 1),
        stop = v(position.x, position.y),
        normal = v(-1, 0),
      }

      self.player = player:get_component("transform")
    end,

    update = function(self)
      for segment in all(segments) do
        local player_position = self.player:get_center_position()
        local player_direction = player_position - segment.start
        local x, y = player_direction.x * segment.normal.x, player_direction.y * segment.normal.y
        local is_player_front = max(x, y) > 0

        if (is_player_front) add(g_walls, segment)
      end
    end,

    get_segments = function(self)
      return segments
    end
  }
end
