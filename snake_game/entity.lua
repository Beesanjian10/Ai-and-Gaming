-- entity.lua
-- An entity is an empty container. Components (small tables of data) are added to it.
local Entity = {}
Entity.__index = Entity

function Entity:new()
  local entity = {
    components = {}
  }
  return setmetatable(entity, Entity)
end

function Entity:addComponent(name, component)
  self.components[name] = component
end

function Entity:getComponent(name)
  return self.components[name]
end

function Entity:hasComponent(name)
  return self.components[name] ~= nil
end

-- The three components. Each one is just a table of data.

function Entity.Position(x, y)
  return {x = x, y = y}
end

function Entity.Movement(dx, dy)
  return {dx = dx, dy = dy}
end

function Entity.Renderer(color, size)
  return {color = color, size = size}
end

return Entity
