function new_transform_comp(x, y, size_x, size_y)
  return {
    name = "transform",
    position = new_vec(x, y),
    size = new_vec(size_x, size_y),
    get_center_position = function(self)
      return new_vec(
        self.position.x + self.size.x / 2,
        self.position.y + self.size.y / 2
      )
    end
  }
end
