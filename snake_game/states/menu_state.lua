-- states/menu_state.lua
local HighScore = require("highscore")

local Menu = {
  highScore = 0
}

-- Called when we switch to the menu
function Menu:enter()
  self.highScore = HighScore:load()
end

function Menu:update(dt)
  -- nothing to update in the menu
end

function Menu:draw()
  -- Make the fonts the first time we draw
  if not self.bigFont then
    self.bigFont = love.graphics.newFont(64)
    self.font = love.graphics.newFont(24)
  end

  local width = love.graphics.getWidth()

  love.graphics.setColor(0.35, 1.0, 0.45)
  love.graphics.setFont(self.bigFont)
  love.graphics.printf("SNAKE", 0, 100, width, "center")

  love.graphics.setColor(1, 1, 1)
  love.graphics.setFont(self.font)
  love.graphics.printf("High Score: " .. self.highScore, 0, 200, width, "center")
  love.graphics.printf("Press ENTER to play", 0, 280, width, "center")
  love.graphics.printf("Arrow keys or WASD to move   -   ESC to quit", 0, 400, width, "center")
end

return Menu
