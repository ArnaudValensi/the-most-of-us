vec={}
function vec:__add(v2)
 return v(self.x+v2.x,self.y+v2.y)
end
function vec:__sub(v2)
 return v(self.x-v2.x,self.y-v2.y)
end
function vec:__mul(a)
 return v(self.x*a,self.y*a)
end
function vec:__pow(v2)
 return self.x*v2.x+self.y*v2.y
end
function vec:__unm()
 return v(-self.x,-self.y)
end
function vec:__eq(v2)
  return self.x==v2.x and self.y==v2.y
 end
-- this is actually length-squared
-- easier to calculate, good enough
function vec:__len()
 return self.x*self.x+self.y*self.y
end
-- normalized vector
function vec:norm()
 return self*(1/sqrt(#self))
end
-- rotated 90-deg clockwise
function vec:rotcw()
 return v(-self.y,self.x)
end
-- force coordinates to
-- integers
function vec:ints()
 return v(flr(self.x),flr(self.y))
end
-- tostring method (uses __call
-- for token-saving, dirty,
-- i know)
function vec:__call()
 return self.x..', '..self.y
end
-- has to be there so
-- our metatable works
-- for both operators
-- and methods
vec.__index=vec

-- creates a new vector
function v(x,y)
 return setmetatable(
  {x=x,y=y},vec
 )
end
