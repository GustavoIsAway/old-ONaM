local Timer  = require("scripts.classes.Timer")
local utils  = require("scripts.utils")
local Button = require("scripts.classes.Button")



local function generateRotationCache(image, step)
  local w, h = image:getWidth(), image:getHeight()
  local maxSize = math.ceil(math.sqrt(w*w + h*h))
  local frames = {}

  for angle = 0, 360 - step, step do
    local canvas = love.graphics.newCanvas(maxSize, maxSize)

    love.graphics.setCanvas(canvas)
    love.graphics.clear()

    love.graphics.push()
    love.graphics.translate(maxSize / 2, maxSize / 2)
    love.graphics.rotate(math.rad(angle))
    love.graphics.draw(image, -w / 2, -h / 2)
    love.graphics.pop()

    love.graphics.setCanvas()
    frames[#frames + 1] = canvas
  end

  return frames
end



local function smoothMove(dt, obj, targetX, targetY)
  if obj.x == targetX and obj.y == targetY then
    return true
  end

  local dx = targetX - obj.x
  local dy = targetY - obj.y
  local dist = math.sqrt(dx*dx + dy*dy)

  if dist <= 0.5 then
    obj.x = targetX
    obj.y = targetY
    obj.velocity = 0
    return true
  end

  local dirX = dx / dist
  local dirY = dy / dist

  local stopDist = (obj.velocity * obj.velocity) / (2 * obj.acc)

  if dist > stopDist then
    obj.velocity = obj.velocity + obj.acc * dt
  else
    obj.velocity = math.max(obj.velocity - obj.acc * dt, 0)
  end

  local move = obj.velocity * dt

  if move >= dist then
    obj.x = targetX
    obj.y = targetY
    obj.velocity = 0
    return true
  end

  obj.x = obj.x + dirX * move
  obj.y = obj.y + dirY * move

  return false
end




local Frog = {}
Frog.__index = Frog

function Frog.new(difficulty)
  local self = setmetatable({}, Frog)

  -- Frog
  self.difficuly = difficulty
  self.movementOpportunityTimer = Timer.new(30 - (difficulty/2))
  self.killTimer                = Timer.new(04)
  self.frames        = generateRotationCache(utils.loadImage("enemies/markoth/markoth.png"), 5)
  self.x             = -115
  self.y             = 520
  self.velocity      = 0
  self.acc           = 1600
  self.currentFrame  = 20
  self.animationTime = 0
  self.frameTime     = 0.017
  self.state         = 0                      -- 0 = embaixo | 1 = em cima

  -- Painel (objeto interno)
  self.panel = {
    frames        = utils.loadImage("enemies/markoth/painel.png"),
    x             = 350,
    y             = 700,
    velocity      = 0,
    acc           = 1600
  }

  self.panelButtons = {}

  -- Controle de movimento
  self.counter   = 5
  self.canGoUp   = true
  self.canGoDown = false

  return self
end




function Frog:goingUp(dt)
  local frogDone  = smoothMove(dt, self, self.x, 300)
  local panelDone = smoothMove(dt, self.panel, self.panel.x, 300)

  if frogDone and panelDone and self.currentFrame == 1 and self.state == 0 then
    self.state = 1
    return false
  end

  self.animationTime = self.animationTime + dt

  if self.animationTime >= self.frameTime then
    if self.currentFrame > 1 then
      self.currentFrame = self.currentFrame - 1
    end
    self.animationTime = 0
  end

  return true
end




function Frog:goingDown(dt)
  local panelDone = smoothMove(dt, self.panel, self.panel.x, 700)
  local frogDone  = smoothMove(dt, self, self.x, 520)

  if panelDone and frogDone and self.currentFrame == 20 and self.state == 1 then
    self.state = 0
    return false
  end

  self.animationTime = self.animationTime + dt

  if self.animationTime >= self.frameTime then
    if self.currentFrame < 20 then
      self.currentFrame = self.currentFrame + 1
    end
    self.animationTime = 0
  end

  return true
end




function Frog:update(dt, mousePos, mouseInputState)
  self.counter = self.counter - dt

  if self.counter <= 0 then
    self.canGoDown = not self.canGoDown
    self.canGoUp   = not self.canGoUp
    self.counter   = 5
  end

  if self.canGoDown then
    self:goingDown(dt)
  elseif self.canGoUp then
    self:goingUp(dt)
  end
end




function Frog:draw()
  love.graphics.draw(self.frames[self.currentFrame], self.x, self.y)
  love.graphics.draw(self.panel.frames, self.panel.x, self.panel.y)
end

return Frog