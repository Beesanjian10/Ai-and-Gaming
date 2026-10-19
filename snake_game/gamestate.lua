-- gamestate.lua
-- State manager: holds the menu and playing states and forwards update/draw to the active one.
local GameState = {}
GameState.__index = GameState

function GameState:new()
  local state = {
    current = "menu",
    states = {
      menu = require("menu_state"),
      playing = require("game_state")
    }
  }
  setmetatable(state, GameState)
  state:switch("menu") -- run the menu's enter() so it starts in a clean state
  return state
end

function GameState:switch(newState)
  assert(self.states[newState], "Unknown state: " .. tostring(newState))

  local old = self.states[self.current]
  if old and old.exit then old:exit() end

  self.current = newState

  local new = self.states[newState]
  if new.enter then new:enter() end
end

function GameState:update(dt)
  self.states[self.current]:update(dt)
end

function GameState:draw()
  self.states[self.current]:draw()
end

return GameState
