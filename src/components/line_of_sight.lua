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
     -- switch direction and tables
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

  function get_value_side(value, light_range)
    local threshold = light_range - 0.01
    if (value > threshold) return 1
    if (value < -threshold) return -1
    return 0
  end

  function get_side_index(pos, light_range)
    local x = get_value_side(pos.x, light_range)
    local y = get_value_side(pos.y, light_range)
    local side_index = 0

    if (x == -1) side_index += 1 --left
    if (y == -1) side_index += 2 --top
    if (x == 1) side_index += 4 --right
    if (y == 1) side_index += 8 --bottom

    return side_index
  end

  function calculate_shadow_volume(light_pos, light_range, wall)
    -- Wall endpoints
    local start, stop = wall.start, wall.stop
    -- Calculate light rays towards start and stop
    local dist_light_to_start, dist_light_to_stop = start - light_pos, stop - light_pos
    -- Extend the rays until they intersect with the
    -- nearest boundary defined by light range
    -- (white points)
    local cs = light_range / max(abs(dist_light_to_start.x), abs(dist_light_to_start.y))
    local ce = light_range / max(abs(dist_light_to_stop.x), abs(dist_light_to_stop.y))
    local projection_start = light_pos + dist_light_to_start * cs
    local projection_stop = light_pos + dist_light_to_stop * ce

    local dist_light_to_proj_start = projection_start - light_pos
    local dist_light_to_proj_stop = projection_stop - light_pos

    printh('dist_light_to_proj_start(): '..dist_light_to_proj_start());
    printh('dist_light_to_proj_stop(): '..dist_light_to_proj_stop());

    local start_side_index = get_side_index(dist_light_to_proj_start, light_range)
    local stop_side_index = get_side_index(dist_light_to_proj_stop, light_range)
    local sides = start_side_index + stop_side_index

    printh('start_side_index: '..start_side_index);
    printh('stop_side_index: '..stop_side_index);
    printh('sides: '..sides);

    local points = {
      projection_start,
      wall.start,
      wall.stop,
      projection_stop
    }

    if (sides == 3) add(points, v(-light_range, -light_range) + light_pos)
    -- if (sides == 3) add(points, v(projection_stop.x, projection_start.y))


    return projection_start, projection_stop, points
  end

  function debug_shadow(wall, projection_start, projection_stop)
    -- printh('start | stop: '..projection_start()..' | '..projection_stop());
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
    local projection_start, projection_stop, points = calculate_shadow_volume(light_pos, light_range, wall)

    debug_shadow(wall, projection_start, projection_stop)

    draw_polygon(points)
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