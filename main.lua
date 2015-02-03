function addSegment(x, y)
  table.insert(snake, {})

  if snake[#snake - 1] then
    snake[#snake].dir = snake[#snake - 1].dir

    snake[#snake].x = x
    snake[#snake].y = y
  end
end

function collisionCheck()
  for k, seg in ipairs(snake) do
    if k > 1 then
      if snake[1].x == seg.x and snake[1].y == seg.y then
        collision = true
      end
    end
  end
end

function moveSegments()
  for k, seg in ipairs(snake) do
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

    if seg.x >= love.window.getWidth() - 20 then
      seg.x = 20
    elseif seg.x <= 10 then
      seg.x = love.window.getWidth() - 30
    elseif seg.y <= 10 then
      seg.y = love.window.getHeight() - 30
    elseif seg.y >= love.window.getHeight() - 20 then
      seg.y = 20
    end
  end
end

function newApple()
  local x = math.random(4, 16) * 10
  local y = math.random(4, 16) * 10

  return x, y
end

function propagateMove()
  for i = #snake, 2, -1 do
    snake[i].dir = snake[i - 1].dir
  end
end

-- LÖVE callbacks

function love.load()
  math.randomseed(os.time())

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

  img = love.graphics.newImage("circle.png")
  font = love.graphics.newFont(20)
  counter = 0
  tick = 0
  score = 0
  highest = 0

  myShader = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords) {
      vec4 pixel = Texel(texture, texture_coords);
      number xFactor = screen_coords.x / love_ScreenSize.x;
      number yFactor = screen_coords.y / love_ScreenSize.y;

      pixel.r = pixel.r * xFactor;
      pixel.g = 1 - pixel.g * xFactor;
      pixel.b = pixel.b * yFactor;
      return pixel;
    }
  ]]
end

function love.draw()
  for k, seg in ipairs(snake) do
    love.graphics.draw(img, seg.x, seg.y, 0, 0.05, 0.05)
  end
  love.graphics.draw(img, appleX, appleY, 0, 0.05, 0.05)

  if collision then
    love.graphics.setFont(font)
    love.graphics.print("You lost!", 75, 75, 0, scale, scale)
    paused = true
    counter = counter + 0.02
    scale = math.abs(math.cos(counter))
  end

  love.graphics.print("Score: " .. score .. " (" .. highest .. ")", 0, 0)

  love.graphics.setShader(myShader)
end

function love.keypressed(key)
  if (key == "left" and dir ~= RIGHT) or (key == "right" and dir ~= LEFT) or (key == "up" and dir ~= DOWN) or (key == "down" and dir ~= UP) then
    snake[1].dir = key
  elseif key == " " and not collision then
    paused = not paused
  end
end

function love.update(dt)
  if not paused then

    time = time and time + dt + dt * 0.005 * tick or 0
  end

  if time >= timeStep then
    time = time - timeStep
    tick = tick + 1
    if tick >= 500 then
      tick = tick - 1
    end

    if score > 0 then
      score = score - 1
    end

    dir = snake[1].dir

    x, y = snake[#snake].x, snake[#snake].y

    moveSegments()

    if snake[1].x == appleX and snake[1].y == appleY then
      addSegment(x, y)
      score = score + 100
      highest = score > highest and score or highest

      local overlapping = true

      while overlapping do
        appleX, appleY = newApple()

        for k, seg in ipairs(snake) do
          if appleX == seg.x and appleY == seg.y then
            overlapping = true
            break
          else
            overlapping = false
          end
        end
      end
    end

    propagateMove()

    collisionCheck()
  end
end