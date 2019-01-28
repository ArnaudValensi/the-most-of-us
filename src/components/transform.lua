function new_transform_comp(x, y, size_x, size_y)
  return {
    name = "transform",
    position = new_vec(x, y),
    size = new_vec(size_x, size_y)
  }
end
