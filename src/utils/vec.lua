function new_vec(x, y)
  return {
    x = x,
    y = y,
    equal = function(self, other) return self.x == other.x and self.y == other.y end,
    add = function(self, other) return new_vec(self.x + other.x, self.y + other.y) end,
    sub = function(self, other) return new_vec(self.x - other.x, self.y - other.y) end,
    scalar_mul = function(self, n) return new_vec(self.x * n, self.y * n) end,
    to_string = function(self) return '('..self.x..', '..self.y..')' end
  }
end
