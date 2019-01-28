function new_wall_comp()
  local segments = {}

  return {
    name = "wall",

    init = function(self)
      local transform = self.game_object:get_component("transform")
      local position = transform.position
      local size = transform.size

      -- Top
      segments[1] = {
        start = new_vec(position.x, position.y),
        stop = new_vec(position.x + size.x - 1, position.y),
        normal = new_vec(0, -1),
      }
      -- Right
      segments[2] = {
        start = new_vec(position.x + size.x - 1, position.y),
        stop = new_vec(position.x + size.x - 1, position.y + size.y - 1),
        normal = new_vec(1, 0),
      }
      -- Bottom
      segments[3] = {
        start = new_vec(position.x + size.x - 1, position.y + size.y - 1),
        stop = new_vec(position.x, position.y + size.y - 1),
        normal = new_vec(0, 1),
      }
      -- Left
      segments[4] = {
        start = new_vec(position.x, position.y + size.y - 1),
        stop = new_vec(position.x, position.y),
        normal = new_vec(-1, 0),
      }
    end,

    late_draw = function(self)
      -- for segment in all(segments) do
      --   -- Draw segment.
      --   line(segment.start.x, segment.start.y, segment.stop.x, segment.stop.y, 8)
      --   -- Draw normal.
      --   line(
      --     segment.start.x + (segment.stop.x - segment.start.x) / 2,
      --     segment.start.y + (segment.stop.y - segment.start.y) / 2,
      --     segment.start.x + (segment.stop.x - segment.start.x) / 2 + segment.normal.x,
      --     segment.start.y + (segment.stop.y - segment.start.y) / 2 + segment.normal.y,
      --     7
      --   )
      -- end
    end,

    get_segments = function(self)
      return segments
    end
  }
end
