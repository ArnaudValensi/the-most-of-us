function new_line_of_sight_comp(segments)
  function round(x)
    return flr(x+0.5)
  end

  function find_polygon_edges(point_a, point_b, left_points, right_points)
    local ax, ay = point_a.x, round(point_a.y)
    local bx, by = point_b.x, round(point_b.y)

    if (ay == by) return

    local x = ax
    local x_distance_at_each_increment = (bx - ax) / abs(by - ay)
    local step = 1

    if by < ay then
     --switch direction and tables
     right_points, step = left_points, -1
    end
    for y = ay, by, step do
     right_points[y] = x
     x += x_distance_at_each_increment
    end
  end

  function draw_polygon(points)
    local left_points, right_points, nb_points = {}, {}, #points
    -- update left_points and right_points using each edge in turn
    for i = 1, nb_points do
     find_polygon_edges(
      points[i],
      points[i % nb_points + 1],
      left_points,
      right_points
     )
    end
    -- use the tables to draw each horizontal line
    for y, left_point in pairs(left_points) do
      local right_point = right_points[y]
      line(left_point, y, right_point, y)
    end
  end

  function calculate_shadow_volume(light_pos, light_range, wall)
    -- Wall endpoints
    local start, stop = wall.start, wall.stop
    -- Calculate light rays towards start and stop
    local dist_light_to_start, dist_light_to_stop = start:sub(light_pos), stop:sub(light_pos)
    -- Extend the rays until they intersect with the
    -- nearest boundary defined by light range
    -- (white points)
    local cs = light_range / max(abs(dist_light_to_start.x), abs(dist_light_to_start.y))
    local ce = light_range / max(abs(dist_light_to_stop.x), abs(dist_light_to_stop.y))
    local projection_start = light_pos:add(dist_light_to_start:scalar_mul(cs))
    local projection_stop = light_pos:add(dist_light_to_stop:scalar_mul(ce))

    return projection_start, projection_stop
  end

  function debug_shadow(wall, projection_start, projection_stop)
    circ(wall.stop.x, wall.stop.y, 2, 2) -- Red
    circ(projection_stop.x, projection_stop.y, 2, 2) -- Red
    circ(projection_start.x, projection_start.y, 2, 1) -- Blue
    circ(wall.start.x, wall.start.y, 2, 1) -- Blue
    line(wall.start.x, wall.start.y, projection_start.x, projection_start.y)
    line(wall.stop.x, wall.stop.y, projection_stop.x, projection_stop.y)
    line(wall.stop.x, wall.stop.y, wall.start.x, wall.start.y)
    line(wall.start.x, wall.start.y, wall.stop.x, wall.stop.y)
    line(projection_start.x, projection_start.y, projection_stop.x, projection_stop.y)
  end

  function compute_wall_shadow(light_pos, light_range, wall)
    local projection_start, projection_stop = calculate_shadow_volume(light_pos, light_range, wall)

    debug_shadow(wall, projection_start, projection_stop)

    draw_polygon({
      wall.stop,
      projection_stop,
      projection_start,
      wall.start
    })
  end

  return {
    name = "line_of_sight",

    init = function(self)
      self.transform = self.game_object:get_component("transform")
    end,

    late_init = function(self)
      self.segments = gameobjects:get_by_name("wall1"):get_component("wall"):get_segments()
    end,

    late_draw = function(self)
      -- Light position and range
      local light_pos = self.transform:get_center_position()
      local light_range = 50
      local wall = self.segments[3]

      compute_wall_shadow(light_pos, light_range, wall)
    end,
  }
end
