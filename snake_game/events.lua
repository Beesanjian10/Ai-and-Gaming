-- events.lua
-- Simple observer pattern: anyone can subscribe to a named event, anyone can emit it.
local Events = {}

local listeners = {} -- event name -> list of callbacks

function Events:subscribe(event, callback)
  listeners[event] = listeners[event] or {}
  table.insert(listeners[event], callback)
end

function Events:emit(event, data)
  local list = listeners[event]
  if not list then return end
  for _, callback in ipairs(list) do
    callback(data)
  end
end

return Events
