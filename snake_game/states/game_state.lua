-- states/game_state.lua
-- The "playing" screen. It holds a SnakeGame and listens for game events.
local SnakeGame = require("snake_game")
local HighScore = require("highscore")
local Events = require("events")

local Playing = {
  game = nil,
  highScore = 0,
  newRecord = false
}

-- Event: the snake ate food
Events:subscribe("food_eaten", function(data)
  print("Score increased to:", data.score)
end)

-- Event: the game ended. Save the score if it is a new record.
Events:subscribe("game_over", function(data)
  if data.score > Playing.highScore then
    Playing.highScore = data.score
    Playing.newRecord = true
    HighScore:save(data.score)
  end
end)

-- Called every time we switch to this state, so each visit is a new game.
function Playing:enter()
  self.game = SnakeGame:new()
  self.highScore = HighScore:load()
  self.newRecord = false
end

function Playing:update(dt)
  if self.game then
    self.game:update(dt)
  end
end

function Playing:draw()
  if not self.game then return end

  if not self.bigFont then
    self.bigFont = love.graphics.newFont(54)
    self.font = love.graphics.newFont(24)
  end

  self.game:draw()

  -- High score at the top right
  love.graphics.setFont(self.font)
  love.graphics.setColor(0.8, 0.8, 0.9)
  love.graphics.printf("High Score: " .. self.highScore, 0, 10, love.graphics.getWidth() - 10, "right")

  -- Game over screen
  if self.game.gameOver then
    local width = love.graphics.getWidth()
    love.graphics.setColor(0, 0, 0, 0.7)
    love.graphics.rectangle("fill", 0, 0, width, love.graphics.getHeight())

    love.graphics.setColor(1, 0.35, 0.35)
    love.graphics.setFont(self.bigFont)
    love.graphics.printf("GAME OVER", 0, 150, width, "center")

    love.graphics.setColor(1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.printf("Score: " .. self.game.score, 0, 230, width, "center")
    if self.newRecord then
      love.graphics.printf("New high score!", 0, 265, width, "center")
    end
    love.graphics.printf("R - play again      ESC - menu", 0, 330, width, "center")
  end
end

function Playing:changeDirection(dx, dy)
  if self.game then
    self.game:changeDirection(dx, dy)
  end
end

function Playing:isGameOver()
  return self.game ~= nil and self.game.gameOver
end

return Playing
