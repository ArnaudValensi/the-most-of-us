function new_vec(x, y)
  return {
    x = x,
    y = y,
    equal = function(self, other) return self.x == other.x and self.y == other.y end
  }
end
