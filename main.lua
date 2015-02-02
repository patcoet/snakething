function addSegment(x, y)
  -- snakeLength = snakeLength and snakeLength + 1 or 0
  -- last = text:sub(text:len())

  -- if last == "s" then
  --   text = text .. "n"
  -- elseif last == "n" then
  --   text = text .. "a"
  -- elseif last == "a" then
  --   text = text .. "k"
  -- elseif last == "k" then
  --   text = text .. "e"
  -- elseif last == "e" then
  --   text = text .. "s"
  -- end

  table.insert(snake, {})

  if snake[#snake - 1] then
    snake[#snake].dir = snake[#snake - 1].dir

    snake[#snake].x = x
    snake[#snake].y = y
  end

  -- text = text and text .. "x" or "x"
end

function collisionCheck()
  for k, seg in ipairs(snake) do
    if k > 1 then
      if snake[1].x == seg.x and snake[1].y == seg.y then
        collision = true
        -- print(snake[1].x, seg.x, snake[1].y, seg.y, k)
      end
    end
  end
end

function moveSegments()
  for k, seg in ipairs(snake) do
    print(k, seg.dir, seg.x, seg.y)
    local dir = seg.dir

    if dir == RIGHT then
      seg.x = seg.x + moveStep
    elseif dir == LEFT then
      seg.x = seg.x - moveStep
    elseif dir == UP then
      seg.y = seg.y - moveStep
    elseif dir == DOWN then
      seg.y = seg.y + moveStep
    end

    if seg.x > love.window.getWidth() then
      seg.x = 0
    elseif seg.x < 0 then
      seg.x = love.window.getWidth()
    elseif seg.y < 0 then
      seg.y = love.window.getHeight()
    elseif seg.y > love.window.getHeight() then
      seg.y = 0
    end
  end
end

-- The snake is described as a table.
-- The head is part 1. On each tick,
-- part n goes in direction n.dir.
-- When the player presses an arrow
-- key, head.dir is updated, and on
-- each tick 5.dir = 4.dir, 4.dir
-- = 3.dir, etc.

function propagateMove()
  for i = #snake, 2, -1 do
    snake[i].dir = snake[i - 1].dir
  end
end

function newApple()
  local x = math.random(4, 16) * 10
  local y = math.random(4, 16) * 10

  return x, y
end

function love.load()
  math.randomseed(os.time())
  love.window.setMode(200, 200)

  RIGHT = "right"
  LEFT = "left"
  UP = "up"
  DOWN = "down"

  dir = RIGHT
  timeStep = 0.2
  moveStep = 10

  snake = {}

  addSegment()
  snake[1].dir = dir
  snake[1].x = 50
  snake[1].y = 50

  appleX, appleY = newApple()
end

function love.draw()
  for k, seg in ipairs(snake) do
    love.graphics.print("x", seg.x, seg.y)
  end
  love.graphics.print(".", appleX, appleY)

  if collision then
    love.graphics.print("You lost!", 100, 100)
    paused = true
  end
end

function love.keypressed(key)
  -- dir = snake[1].dir
  if (key == "left" and dir ~= RIGHT) or (key == "right" and dir ~= LEFT) or (key == "up" and dir ~= DOWN) or (key == "down" and dir ~= UP) then
    snake[1].dir = key
  elseif key == " " then
    paused = not paused
  end
end

function love.update(dt)
  if not paused then
    time = time and time + dt or 0
  end

  if time >= timeStep then
    time = time - timeStep

    dir = snake[1].dir

    x, y = snake[#snake].x, snake[#snake].y

    moveSegments()

    if snake[1].x == appleX and snake[1].y == appleY then
      print("adding segment")
      addSegment(x, y)
      appleX, appleY = newApple()
    end

    propagateMove()

    collisionCheck()

    print("")

  end
end