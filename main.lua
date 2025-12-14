math.randomseed(os.time())
math.random(); math.random(); math.random()

local Game = require("scripts.classes.Game")

-- BASE
local baseWidth, baseHeight = 800, 600
local game = Game.new()
local renderCanvas = love.graphics.newCanvas(baseWidth, baseHeight)

-- VIEWPORT
local offsetX = 0
local offsetY = 0
local currentScale = 1

-- INPUT
local mousePos = {}
local mouseIsDown = {false, false, false}
local mouseWasDown = {false, false, false}
local mouseClick = {false, false, false}

love.graphics.setDefaultFilter("nearest","nearest")

function love.resize(w, h)
  local scaleX, scaleY = w / baseWidth, h / baseHeight
  currentScale = math.min(scaleX, scaleY)
  offsetX = (w - baseWidth * currentScale) / 2
  offsetY = (h - baseHeight * currentScale) / 2

  game.currentScale = currentScale
  game.offsetX = offsetX
  game.offsetY = offsetY
end

function love.update(dt)
  -- UPDATE DO MOUSE
  mousePos[1] = (love.mouse.getX() - offsetX) / currentScale
  mousePos[2] = (love.mouse.getY() - offsetY) / currentScale
  mouseIsDown[1], mouseIsDown[2], mouseIsDown[3] =
    love.mouse.isDown(1), love.mouse.isDown(2), love.mouse.isDown(3)

  for i = 1, 3 do
    if mouseIsDown[i] and not mouseWasDown[i] then
      mouseClick[i] = true
    else
      mouseClick[i] = false
    end
  end

  mouseWasDown[1], mouseWasDown[2], mouseWasDown[3] =
    mouseIsDown[1], mouseIsDown[2], mouseIsDown[3]

  game:update(dt, mouseIsDown, mouseClick, mousePos)
end

function love.keypressed(key)
  if key == "q" then
    game.showDebug = not game.showDebug
  end
end

function love.draw()
  love.graphics.setCanvas(renderCanvas)
  love.graphics.clear(0, 0, 0, 1)

  game:draw()

  love.graphics.setCanvas()
  love.graphics.push()
  love.graphics.translate(offsetX, offsetY)
  love.graphics.scale(currentScale, currentScale)
  love.graphics.draw(renderCanvas, 0, 0)
  love.graphics.pop()
end
