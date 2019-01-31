function is_transform_colliding_map_cell(position, size)
  function is_vec_colliding_cell(vec)
    return fget(mget(vec.x / 8, vec.y / 8), 0)
  end

  local top_left = v(
    position.x,
    position.y
  )
  local top_right = v(
    position.x + size.x - 1,
    position.y
  )
  local bottom_right = v(
    position.x + size.x - 1,
    position.y + size.y - 1
  )
  local bottom_left = v(
    position.x,
    position.y + size.y - 1
  )

  return is_vec_colliding_cell(top_left)
   or is_vec_colliding_cell(top_right)
   or is_vec_colliding_cell(bottom_right)
   or is_vec_colliding_cell(bottom_left)
end
