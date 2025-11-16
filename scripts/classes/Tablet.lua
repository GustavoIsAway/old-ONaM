local utils = require("scripts.utils")
local CollBox = require("scripts.classes.CollisionBox")
local Timer = require("scripts.classes.Timer")

local Tablet = {}
Tablet.__index = Tablet



function Tablet.new(screenX, screenY)
  local self = setmetatable({}, Tablet)
  self.isOn = false
  self.tabletDim = {screenX, screenY}
  self.currentFrame = 0
  self.isMoving = false
  self.animation = -1
  self.animTimer = Timer.new(0.025)

  self.frames = {
    utils.loadImage("pannel/1.png"),
    utils.loadImage("pannel/2.png"),
    utils.loadImage("pannel/3.png"),
    utils.loadImage("pannel/4.png"),
    utils.loadImage("pannel/5.png"),
    utils.loadImage("pannel/6.png"),
  }

  -- Botão principal de abrir/fechar o tablet
  self.Button = {}
  self.Button.x, self.Button.y = 150, 565
  self.Button.frames = { utils.loadImage("botaoPrincipal.png") }
  self.Button.collision = CollBox.new(
    self.Button.x,
    self.Button.y,
    self.Button.frames[1]:getWidth(),
    screenY - self.Button.y
  )
  self.Button.intouchable = false
  self.Button.activated = false
  self.Button.mouseOn = false

  return self
end



function Tablet:update(dt, mouseX, mouseY)
  local mainButtonCollision = self.Button.collision:checkMouseColl(mouseX, mouseY)
  local animFinished = (self.currentFrame == 0 or self.currentFrame == 6)

  if mainButtonCollision then
    if not self.Button.mouseOn then
      self.Button.mouseOn = true
      if animFinished and not self.isMoving then
        self.Button.activated = true
      else
        self.Button.activated = false
      end
    else
      self.Button.activated = false
    end
  else
    self.Button.mouseOn = false
    self.Button.activated = false
  end

  if self.Button.activated then
    self.isMoving = true
    self.animation = (self.currentFrame == 0) and 1 or -1
  end

  if self.isMoving then
    self.animTimer:update(dt)
    if self.animTimer:isJammed() then
      self.currentFrame = self.currentFrame + self.animation
      self.animTimer:reset()
      if self.currentFrame >= 6 then
        self.currentFrame = 6
        self.isMoving = false
      elseif self.currentFrame <= 0 then
        self.currentFrame = 0
        self.isMoving = false
      end
    end
  end

  self.isOn = (self.currentFrame == 6)
end



function Tablet:getTabletState()
  return self.isOn
end



function Tablet:draw()
  if self.currentFrame > 0 then
    love.graphics.draw(self.frames[self.currentFrame], self.x, self.y)
  end

  love.graphics.draw(self.Button.frames[1], self.Button.x, self.Button.y)
end



return Tablet
