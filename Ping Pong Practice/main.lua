
-- Part 1: window, paddles and ball drawing

-- game constants
WINDOW_WIDTH = 800
WINDOW_HEIGHT = 600

PADDLE_WIDTH = 15
PADDLE_HEIGHT = 100
PADDLE_SPEED = 400
PADDLE_MARGIN = 30   -- distance from the side of the screen

BALL_SIZE = 15

-- players are tables
player1 = {
    x = PADDLE_MARGIN,
    y = WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2,
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    speed = PADDLE_SPEED
}

player2 = {
    x = WINDOW_WIDTH - PADDLE_MARGIN - PADDLE_WIDTH,
    y = WINDOW_HEIGHT / 2 - PADDLE_HEIGHT / 2,
    width = PADDLE_WIDTH,
    height = PADDLE_HEIGHT,
    speed = PADDLE_SPEED
}

-- ball starts in the middle
ball = {
    x = WINDOW_WIDTH / 2 - BALL_SIZE / 2,
    y = WINDOW_HEIGHT / 2 - BALL_SIZE / 2,
    width = BALL_SIZE,
    height = BALL_SIZE
}

function love.load()
    love.window.setTitle("Pong")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
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
end

function love.draw()
    love.graphics.setColor(1, 1, 1)

    -- dashed line in the middle
    for y = 0, WINDOW_HEIGHT, 30 do
        love.graphics.rectangle("fill", WINDOW_WIDTH / 2 - 2, y, 4, 15)
    end

    -- paddles
    love.graphics.rectangle("fill", player1.x, player1.y, player1.width, player1.height)
    love.graphics.rectangle("fill", player2.x, player2.y, player2.width, player2.height)

    -- ball
    love.graphics.rectangle("fill", ball.x, ball.y, ball.width, ball.height)
end
