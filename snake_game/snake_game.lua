-- snake_game.lua
-- The rules of Snake: moving, eating, growing and colliding.
local Vector2 = require("vector2")
local Entity = require("entity")
local Events = require("events")

local SnakeGame = {}
SnakeGame.__index = SnakeGame

-- Board settings
SnakeGame.COLS = 30   -- cells across
SnakeGame.ROWS = 20   -- cells down
SnakeGame.CELL = 24   -- pixels per cell
SnakeGame.TOP = 40    -- pixels above the board for the score

local STEP_TIME = 0.12 -- seconds between snake moves

local HEAD_COLOR = {0.35, 1.0, 0.45}
local BODY_COLOR = {0.15, 0.7, 0.3}
local FOOD_COLOR = {1.0, 0.3, 0.3}

-- Make an entity for one snake segment. Only the head has Movement.
local function makeSegment(x, y, isHead)
  local segment = Entity:new()
  segment:addComponent("position", Entity.Position(x, y))
  if isHead then
    segment:addComponent("renderer", Entity.Renderer(HEAD_COLOR, SnakeGame.CELL - 2))
    segment:addComponent("movement", Entity.Movement(1, 0))
  else
    segment:addComponent("renderer", Entity.Renderer(BODY_COLOR, SnakeGame.CELL - 2))
  end
  return segment
end

local function makeFood(x, y)
  local food = Entity:new()
  food:addComponent("position", Entity.Position(x, y))
  food:addComponent("renderer", Entity.Renderer(FOOD_COLOR, SnakeGame.CELL - 2))
  return food
end

-- The grid cell an entity is on, as a Vector2
local function cellOf(entity)
  local position = entity:getComponent("position")
  return Vector2:new(position.x, position.y)
end

function SnakeGame:new()
  local game = {
    snake = {makeSegment(10, 10, true)}, -- snake[1] is the head
    direction = Vector2:new(1, 0),       -- the way we are moving now
    nextDirection = Vector2:new(1, 0),   -- the way the player wants to go
    food = makeFood(15, 15),
    score = 0,
    gameOver = false,
    timer = 0
  }
  return setmetatable(game, SnakeGame)
end

-- Pick random cells until we find one the snake is not on.
function SnakeGame:spawnFood()
  while true do
    local cell = Vector2:new(math.random(0, self.COLS - 1), math.random(0, self.ROWS - 1))
    local free = true
    for _, segment in ipairs(self.snake) do
      if cellOf(segment) == cell then
        free = false
      end
    end
    if free then
      return makeFood(cell.x, cell.y)
    end
  end
end

function SnakeGame:update(dt)
  if self.gameOver then return end

  -- Add up time. When enough has passed, move one step.
  self.timer = self.timer + dt
  while self.timer >= STEP_TIME and not self.gameOver do
    self.timer = self.timer - STEP_TIME
    self:step()
  end
end

-- Move the snake one cell.
function SnakeGame:step()
  self.direction = self.nextDirection

  local head = self.snake[1]
  local movement = head:getComponent("movement")
  movement.dx = self.direction.x
  movement.dy = self.direction.y

  local newCell = cellOf(head) + Vector2:new(movement.dx, movement.dy)

  -- Hit a wall?
  if newCell.x < 0 or newCell.x >= self.COLS or newCell.y < 0 or newCell.y >= self.ROWS then
    self:endGame()
    return
  end

  local eating = (newCell == cellOf(self.food))

  -- Hit ourselves? (When not eating, the tail moves away, so skip it.)
  local last = #self.snake
  if not eating then last = last - 1 end
  for i = 1, last do
    if cellOf(self.snake[i]) == newCell then
      self:endGame()
      return
    end
  end

  -- The old head becomes a body segment, and a new head goes in front.
  head:getComponent("renderer").color = BODY_COLOR
  head.components.movement = nil
  table.insert(self.snake, 1, makeSegment(newCell.x, newCell.y, true))

  if eating then
    self.score = self.score + 10
    if #self.snake >= self.COLS * self.ROWS then
      self:endGame() -- the board is full, nowhere to put food
      return
    end
    self.food = self:spawnFood()
    Events:emit("food_eaten", {score = self.score})
  else
    table.remove(self.snake) -- remove the tail so the snake does not grow
  end
end

function SnakeGame:endGame()
  self.gameOver = true
  Events:emit("game_over", {score = self.score})
end

local function drawEntity(entity)
  local position = entity:getComponent("position")
  local renderer = entity:getComponent("renderer")
  local cell = SnakeGame.CELL
  local padding = (cell - renderer.size) / 2
  love.graphics.setColor(renderer.color)
  love.graphics.rectangle("fill",
    position.x * cell + padding,
    SnakeGame.TOP + position.y * cell + padding,
    renderer.size, renderer.size)
end

function SnakeGame:draw()
  -- Board
  love.graphics.setColor(0.08, 0.09, 0.12)
  love.graphics.rectangle("fill", 0, self.TOP, self.COLS * self.CELL, self.ROWS * self.CELL)

  -- Food and snake
  drawEntity(self.food)
  for _, segment in ipairs(self.snake) do
    drawEntity(segment)
  end

  -- Score
  love.graphics.setColor(1, 1, 1)
  love.graphics.print("Score: " .. self.score, 10, 10)
end

-- The player pressed a direction key.
function SnakeGame:changeDirection(dx, dy)
  -- Do not allow turning straight back into ourselves.
  if dx == -self.direction.x and dy == -self.direction.y then
    return
  end
  self.nextDirection = Vector2:new(dx, dy)
end

return SnakeGame
