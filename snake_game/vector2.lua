-- vector2.lua
-- A Vector2 is a pair of numbers (x, y). With metamethods we can use
-- + and == directly on vectors, e.g.  Vector2:new(1, 2) + Vector2:new(3, 4)
local Vector2 = {}
Vector2.__index = Vector2

function Vector2:new(x, y)
  return setmetatable({x = x or 0, y = y or 0}, Vector2)
end

-- a + b
function Vector2:__add(other)
  return Vector2:new(self.x + other.x, self.y + other.y)
end

-- a == b  (true when both numbers match)
function Vector2:__eq(other)
  return self.x == other.x and self.y == other.y
end

-- print(v) shows something readable
function Vector2:__tostring()
  return "Vector2(" .. self.x .. ", " .. self.y .. ")"
end

return Vector2
