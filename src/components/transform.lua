function new_transform_comp(x, y, size_x, size_y)
  return {
    name = "transform",
    position = v(x, y),
    size = v(size_x or 0, size_y or 0),
    get_center_position = function(self)
      return v(
        self.position.x + self.size.x / 2,
        self.position.y + self.size.y / 2
      )
    end
  }
end
