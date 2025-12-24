local Timer  = require("scripts.classes.Timer")
local utils  = require("scripts.utils")
local Button = require("scripts.classes.Button")

-- Deus me perdoe: o GPT escreveu metade do que tá aqui.



-- =========================
-- Utils
-- =========================

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

  obj.x = obj.x + dirX * move
  obj.y = obj.y + dirY * move

  return false
end



-- =========================
-- Frog
-- =========================

local Frog = {}
Frog.__index = Frog

Frog.STATE_HIDDEN     = 0
Frog.STATE_RISING     = 1
Frog.STATE_ACTIVE     = 2
Frog.STATE_DESCENDING = 3

Frog.GENIUS_FLASH_ON  = 0
Frog.GENIUS_FLASH_OFF = 1
Frog.GENIUS_WAITING   = 2
Frog.GENIUS_DONE      = 3



function Frog.new(difficulty)
  local self = setmetatable({}, Frog)

  self.difficulty = difficulty

  self.movementOpportunityTimer = Timer.new(16 - (difficulty / 6))
  self.killTimer                = Timer.new(17 - (difficulty / 4))

  self.frames        = generateRotationCache(utils.loadImage("enemies/markoth/markoth.png"), 5)
  self.currentFrame  = 20
  self.animationTime = 0
  self.frameTime     = 0.017

  self.x        = -115
  self.y        = 520
  self.velocity = 0
  self.acc      = 1600

  self.panel = {
    frames   = utils.loadImage("enemies/markoth/painel.png"),
    x        = 350,
    y        = 700,
    velocity = 0,
    acc      = 1600
  }

  self.state         = Frog.STATE_HIDDEN
  self.previousState = nil
  self.killState     = false

  -- Genius
  self.sequence = {1, 3, 2, 4}
  self.seqIndex = 1

  self.geniusState   = Frog.GENIUS_FLASH_ON
  self.flashIndex    = 1
  self.flashTimer    = 0
  self.flashInterval = 0.5

  self.inputTimer   = 0
  self.inputTimeout = 4.0

  self.startDelay      = 2.0
  self.startDelayTimer = 0
  self.waitingStart    = false

  -- Sons
  self.sndFrogActive   = utils.loadSound("frog/frogActive.ogg", "static")
  self.sndFrogGameOver  = utils.loadSound("frog/frogGameOver.ogg", "static")
  self.sndGeniusFail   = utils.loadSound("frog/geniusFail.ogg", "static")
  self.sndGeniusWin    = utils.loadSound("frog/geniusWin.ogg", "static")

  self.sndButtons = {
    utils.loadSound("frog/b1.ogg", "static"),
    utils.loadSound("frog/b2.ogg", "static"),
    utils.loadSound("frog/b3.ogg", "static"),
    utils.loadSound("frog/b4.ogg", "static")
  }

  -- Buttons com CALLBACKS
  self.buttons = {
    Button.new(370, 280, {125, 125}, "1", "rect", function()
      love.audio.play(self.sndButtons[1]:clone())
      self:onGeniusInput(1)
    end),

    Button.new(505, 280, {125, 125}, "2", "rect", function()
      love.audio.play(self.sndButtons[2]:clone())
      self:onGeniusInput(2)
    end),

    Button.new(505, 415, {125, 125}, "3", "rect", function()
      love.audio.play(self.sndButtons[3]:clone())
      self:onGeniusInput(3)
    end),

    Button.new(370, 415, {125, 125}, "4", "rect", function()
      love.audio.play(self.sndButtons[4]:clone())
      self:onGeniusInput(4)
    end)
  }

  self.buttons[1]:setColor(utils.colors.CL_SOFT_GREEN)
  self.buttons[2]:setColor(utils.colors.CL_SOFT_BLUE)
  self.buttons[3]:setColor(utils.colors.CL_SOFT_RED)
  self.buttons[4]:setColor(utils.colors.CL_SOFT_YELLOW)

  self:makeVanishButtons()

  return self
end



-- =========================
-- Genius logic
-- =========================

function Frog:onGeniusInput(id)
  if self.state ~= Frog.STATE_ACTIVE then return end
  if self.geniusState ~= Frog.GENIUS_WAITING then return end

  if id == self.sequence[self.seqIndex] then
    self.seqIndex = self.seqIndex + 1
    self.inputTimer = 0

    if self.seqIndex > #self.sequence then
      self:startDescending()
    end
  else
    self.killState = true
    self:startDescending()
  end
end



function Frog:resetGenius()
  self.seqIndex    = 1
  self.flashIndex  = 1
  self.flashTimer  = 0
  self.inputTimer  = 0
  self.geniusState = Frog.GENIUS_FLASH_ON
  self:makeVanishButtons()

  local first = self.sequence[1]
  love.audio.play(self.sndButtons[first]:clone())
  self.buttons[first]:makeAppear()
end



-- =========================
-- Update
-- =========================

function Frog:update(dt, mousePos, mouseInputState, cameraOn)
  if self.difficulty == 0 then return end
  if cameraOn then self:makeVanishButtons() end

  if self.state == Frog.STATE_HIDDEN then
    self.movementOpportunityTimer:update(dt)

    if self.movementOpportunityTimer:isJammed() then
      if math.random(1, 20) <= self.difficulty then
        self.sequence = {
          math.random(1,4),
          math.random(1,4),
          math.random(1,4),
          math.random(1,4),
        }
        self.state = Frog.STATE_RISING
      end
      self.movementOpportunityTimer:set(0)
    end

  elseif self.state == Frog.STATE_RISING then
    self.sndFrogActive:play()
    self:updateRising(dt)

  elseif self.state == Frog.STATE_ACTIVE then
    self:updateGeniusState(dt)

  elseif self.state == Frog.STATE_DESCENDING then
    self:updateDescending(dt)
  end

  self:updateButtons(mousePos, mouseInputState)

  return self.killState
end



function Frog:updateGeniusState(dt)
  if self.waitingStart then
    self.startDelayTimer = self.startDelayTimer + dt

    if self.startDelayTimer >= self.startDelay then
      self.waitingStart = false
      self:resetGenius()
    end

    return
  end


  self.flashTimer = self.flashTimer + dt

  if self.geniusState == Frog.GENIUS_FLASH_ON then
    if self.flashTimer >= self.flashInterval then
      self.flashTimer = 0
      self:makeVanishButtons()
      self.geniusState = Frog.GENIUS_FLASH_OFF
    end

  elseif self.geniusState == Frog.GENIUS_FLASH_OFF then
    if self.flashTimer >= self.flashInterval * 0.3 then
      self.flashTimer = 0
      self.flashIndex = self.flashIndex + 1

      if self.flashIndex > #self.sequence then
        self:makeAppearButtons()
        self.geniusState = Frog.GENIUS_WAITING
      else
        local btn = self.sequence[self.flashIndex]
        love.audio.play(self.sndButtons[btn]:clone())
        self.buttons[btn]:makeAppear()
        self.geniusState = Frog.GENIUS_FLASH_ON
      end
    end

  elseif self.geniusState == Frog.GENIUS_WAITING then
    self.inputTimer = self.inputTimer + dt

    if self.inputTimer >= self.inputTimeout then
      self.killState = true
      self:startDescending()
    end
  end
end



-- =========================
-- Movement
-- =========================

function Frog:updateRising(dt)
  local frogDone  = smoothMove(dt, self, self.x, 300)
  local panelDone = smoothMove(dt, self.panel, self.panel.x, 260)

  self:updateAnimation(dt, -1)

  if frogDone and panelDone and self.currentFrame == 1 then
    self.state = Frog.STATE_ACTIVE
    self.waitingStart = true
    self.startDelayTimer = 0
  end
end



function Frog:startDescending()
  self.state = Frog.STATE_DESCENDING
  self.geniusState = Frog.GENIUS_DONE
  self:makeVanishButtons()

  if self.killState then
    love.audio.play(self.sndGeniusFail:clone())
  else
    love.audio.play(self.sndGeniusWin:clone())
  end
end



function Frog:updateDescending(dt)
  local frogDone  = smoothMove(dt, self, self.x, 520)
  local panelDone = smoothMove(dt, self.panel, self.panel.x, 700)

  self:updateAnimation(dt, 1)

  if frogDone and panelDone and self.currentFrame == 20 then
    self.state = Frog.STATE_HIDDEN
    self.movementOpportunityTimer:set(0)
  end
end



function Frog:updateAnimation(dt, dir)
  self.animationTime = self.animationTime + dt

  if self.animationTime >= self.frameTime then
    self.currentFrame = self.currentFrame + dir
    self.currentFrame = math.max(1, math.min(20, self.currentFrame))
    self.animationTime = 0
  end
end



-- =========================
-- Draw / Buttons
-- =========================

function Frog:draw()
  love.graphics.draw(self.frames[self.currentFrame], self.x, self.y)
  love.graphics.draw(self.panel.frames, self.panel.x, self.panel.y)
  self:drawButtons()
end



function Frog:drawButtons()
  for _, b in ipairs(self.buttons) do
    b:draw()
  end
end



function Frog:makeVanishButtons()
  for _, b in ipairs(self.buttons) do
    b:makeVanish()
  end
end



function Frog:makeAppearButtons()
  for _, b in ipairs(self.buttons) do
    b:makeAppear()
  end
end



function Frog:updateButtons(mPos, mClicks)
  for _, b in ipairs(self.buttons) do
    b:update(mPos[1], mPos[2], mClicks[1])
  end
end



return Frog
