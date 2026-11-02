
-- Part 1: window, paddles and ball drawing
-- Part 2: ball movement, bounces, collision and score

-- game constants
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

PADDLE_WIDTH = 15
PADDLE_HEIGHT = 100
PADDLE_SPEED = 400
PADDLE_MARGIN = 30   -- distance from the side of the screen

BALL_SIZE = 15
BALL_SPEED_X = 200   -- pixels per second
BALL_SPEED_Y = 100

-- my own change: the ball gets a bit faster every time it hits a paddle
SPEED_UP = 1.05

-- players are tables
player1 = {
    x = PADDLE_MARGIN,
    y = WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2,
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    speed = PADDLE_SPEED,
    score = 0,
    color = {0.3, 0.6, 1}   -- my own change: blue paddle
}

player2 = {
    x = WINDOW_WIDTH - PADDLE_MARGIN - PADDLE_WIDTH,
    y = WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2,
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    speed = PADDLE_SPEED,
    score = 0,
    color = {1, 0.4, 0.4}   -- my own change: red paddle
}

-- ball starts in the middle, dx and dy are the velocity
ball = {
    x = WINDOW_WIDTH / 2 - BALL_SIZE / 2,
    y = WINDOW_HEIGHT / 2 - BALL_SIZE / 2,
    width = BALL_SIZE,
    height = BALL_SIZE,
    dx = BALL_SPEED_X,
    dy = BALL_SPEED_Y
}

-- puts the ball back in the center
-- direction is 1 (go right) or -1 (go left)
function resetBall(direction)
    ball.x = WINDOW_WIDTH / 2 - BALL_SIZE / 2
    ball.y = WINDOW_HEIGHT / 2 - BALL_SIZE / 2
    ball.dx = BALL_SPEED_X * direction
    if love.math.random(2) == 1 then
        ball.dy = BALL_SPEED_Y
    else
        ball.dy = -BALL_SPEED_Y
    end
end

-- AABB collision: returns true if the two rectangles overlap
function checkCollision(a, b)
    if a.x < b.x + b.width and
       a.x + a.width > b.x and
       a.y < b.y + b.height and
       a.y + a.height > b.y then
        return true
    end
    return false
end

function love.load()
    love.window.setTitle("Pong")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    scoreFont = love.graphics.newFont(48)
end

function love.update(dt)
    -- player 1 uses W and S
    if love.keyboard.isDown("w") then
        player1.y = player1.y - player1.speed * dt
    end
    if love.keyboard.isDown("s") then
        player1.y = player1.y + player1.speed * dt
    end

    -- player 2 uses up and down arrows
    if love.keyboard.isDown("up") then
        player2.y = player2.y - player2.speed * dt
    end
    if love.keyboard.isDown("down") then
        player2.y = player2.y + player2.speed * dt
    end

    -- don't let the paddles go off the screen
    if player1.y < 0 then
        player1.y = 0
    end
    if player1.y + player1.height > WINDOW_HEIGHT then
        player1.y = WINDOW_HEIGHT - player1.height
    end
    if player2.y < 0 then
        player2.y = 0
    end
    if player2.y + player2.height > WINDOW_HEIGHT then
        player2.y = WINDOW_HEIGHT - player2.height
    end

    -- move the ball (velocity * dt so it is the same on every computer)
    ball.x = ball.x + ball.dx * dt
    ball.y = ball.y + ball.dy * dt

    -- bounce on the top wall
    if ball.y < 0 then
        ball.y = 0
        ball.dy = -ball.dy
    end

    -- bounce on the bottom wall
    if ball.y + ball.height > WINDOW_HEIGHT then
        ball.y = WINDOW_HEIGHT - ball.height
        ball.dy = -ball.dy
    end

    -- hit the left paddle
    if checkCollision(ball, player1) then
        ball.dx = -ball.dx * SPEED_UP
        -- move the ball outside the paddle so it doesn't get stuck
        ball.x = player1.x + player1.width
    end

    -- hit the right paddle
    if checkCollision(ball, player2) then
        ball.dx = -ball.dx * SPEED_UP
        ball.x = player2.x - ball.width
    end

    -- ball went out on the left, player 2 scores
    if ball.x + ball.width < 0 then
        player2.score = player2.score + 1
        resetBall(1)
    end

    -- ball went out on the right, player 1 scores
    if ball.x > WINDOW_WIDTH then
        player1.score = player1.score + 1
        resetBall(-1)
    end
end

function love.draw()
    love.graphics.setColor(1, 1, 1)

    -- dashed line in the middle
    for y = 0, WINDOW_HEIGHT, 30 do
        love.graphics.rectangle("fill", WINDOW_WIDTH / 2 - 2, y, 4, 15)
    end

    -- scores
    love.graphics.setFont(scoreFont)
    love.graphics.print(player1.score, WINDOW_WIDTH / 2 - 80, 20)
    love.graphics.print(player2.score, WINDOW_WIDTH / 2 + 50, 20)

    -- paddles (each one has its own color)
    love.graphics.setColor(player1.color)
    love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
    love.graphics.setColor(player2.color)
    love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)

    -- ball (back to white)
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
end
