-- main.lua  (entry point: run with `love .` from inside this folder)

-- Let require("menu_state") / require("game_state") find files in states/
package.path = "states/?.lua;" .. package.path

local GameState = require("gamestate")
local Input = require("input")
local SnakeGame = require("snake_game")

local gameState = GameState:new()

-- One Input (command pattern) per state: keys are bound to functions.
local inputs = {menu = Input:new(), playing = Input:new()}

-- Menu keys
inputs.menu:bind("return", function() gameState:switch("playing") end)
inputs.menu:bind("kpenter", function() gameState:switch("playing") end)
inputs.menu:bind("escape", function() love.event.quit() end)

-- Playing keys
local function bindDirection(keys, dx, dy)
  for _, key in ipairs(keys) do
    inputs.playing:bind(key, function()
      gameState.states.playing:changeDirection(dx, dy)
    end)
  end
end
bindDirection({"up", "w"}, 0, -1)
bindDirection({"down", "s"}, 0, 1)
bindDirection({"left", "a"}, -1, 0)
bindDirection({"right", "d"}, 1, 0)

inputs.playing:bind("r", function()
  if gameState.states.playing:isGameOver() then gameState:switch("playing") end
end)
inputs.playing:bind("escape", function() gameState:switch("menu") end)

function love.load()
  love.window.setTitle("Snake")
  love.window.setMode(SnakeGame.COLS * SnakeGame.CELL, SnakeGame.TOP + SnakeGame.ROWS * SnakeGame.CELL)
  math.randomseed(os.time())
end

function love.update(dt)
  gameState:update(dt)
end

function love.draw()
  gameState:draw()
end

function love.keypressed(key)
  inputs[gameState.current]:handleKey(key)
end
