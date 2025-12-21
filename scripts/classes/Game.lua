local utils         = require("scripts.utils")
local Timer         = require("scripts.classes.Timer")
local TabletSystem  = require("scripts.classes.TabletSystem")
local Tablet        = require("scripts.classes.Tablet")
local Clock         = require("scripts.classes.Clock")
local Sock          = require("scripts.classes.enemies.Sock")
local Bear          = require("scripts.classes.enemies.Bear")
local Snake         = require("scripts.classes.enemies.Snake")
local EyeEnemy      = require("scripts.classes.enemies.EyeEnemy")
local Frog          = require("scripts.classes.enemies.Frog")
local Button        = require("scripts.classes.Button")


local Game = {}
Game.__index = Game


function Game.new()
  local self = setmetatable({}, Game)
  math.randomseed(os.time())
  math.random(); math.random(); math.random()

  -- ESCALA / VIEWPORT
  self.baseWidth, self.baseHeight = 800, 600
  self.currentScale = 1
  self.offsetX = 0
  self.offsetY = 0
  self.hDivision = 6

  -- BACKGROUND
  self.Bck = {image = utils.loadImage("Sala.jpg"), x = 0, y = -90, speed = 0}

  -- TELA
  self.painel = Tablet.new(self.baseWidth, self.baseHeight)
  self.sistemaTablet = TabletSystem.new(self.baseWidth, self.baseHeight)
  self.randomButton = Button.new(368, 277, {125, 125}, "Oi mae", "rect", nil)
  self.randomButton:setColor(utils.colors.CL_SOFT_GREEN)

  -- INPUT
  self.mousePos = {}
  self.mouseIsDown  = {false, false, false}
  self.mouseWasDown = {false, false, false}
  self.mouseClick   = {false, false, false}

  -- DEBUG / ESTADO
  self.jeffKill  = nil
  self.meiaKill  = nil
  self.lennyKill = nil

  self.bearKillOrStall = {}
  self.showDebug    = true
  self.generalTimer = Timer.new(nil)
  self.mode         = nil
  self.playerCamera = nil
  self.clock        = Clock.new(4, 576)

  -- INIMIGOS
  self.jeffWarzatski = EyeEnemy.new(0, 0, 20)
  self.lenny        = Snake.new(0, 0, 20)
  self.meia         = Sock.new(0, 0, 20)
  self.urso         = Bear.new(0, 0, 20)
  self.markoth      = Frog.new(20)

  return self
end




function Game:update(dt, mouseIsDown, mouseClick, mousePos)
  -- INTERNALIZA INPUT
  self.mouseIsDown = mouseIsDown
  self.mouseClick  = mouseClick
  self.mousePos    = mousePos

  self.generalTimer:update(dt)
  self.playerCamera, self.mode = self.sistemaTablet:getCamera()

  -- MOVIMENTO DO BACKGROUND
  if not self.painel:getTabletState() then
    if self.mousePos[1] > self.baseWidth - (self.baseWidth / self.hDivision) then
      self.Bck.x = self.Bck.x - 600 * dt
    elseif self.mousePos[1] < self.baseWidth / self.hDivision then
      self.Bck.x = self.Bck.x + 600 * dt
    end

    local imgW = self.Bck.image:getWidth()
    if self.Bck.x > 0 then self.Bck.x = 0 end
    if self.Bck.x < self.baseWidth - imgW then
      self.Bck.x = self.baseWidth - imgW
    end
  end

  -- UPDATE DAS CLASSES
  self.clock:update(dt)
  self.painel:update(dt, self.mousePos[1], self.mousePos[2])
  self.sistemaTablet:update(
    dt,
    self.mousePos[1],
    self.mousePos[2],
    self.mouseClick,
    self.painel.isOn
  )

  self.jeffKill =
    self.jeffWarzatski:update(
      dt,
      {self.playerCamera, self.mode},
      self.painel.isOn,
      self.bearKillOrStall[2]
    )

  self.lennyKill =
    self.lenny:update(
      dt,
      {self.playerCamera, self.mode},
      self.painel.isOn,
      self.sistemaTablet:getLockedDuct(),
      self.bearKillOrStall[2]
    )

  self.meiaKill =
    self.meia:update(
      dt,
      {self.playerCamera, self.mode},
      self.painel.isOn,
      self.bearKillOrStall[2]
    )

  self.bearKillOrStall =
    self.urso:update(
      dt,
      self.mousePos,
      self.mouseClick,
      self.painel.isOn
    )

  self.markothKill = 
    self.markoth:update(
      dt,
      self.mousePos,
      self.mouseClick
    )

  self.randomButton:update(mousePos[1], mousePos[2], mouseClick[1])
end




function Game:drawDebug()
  love.graphics.setColor(1,1,1,1)
  local y = 4
  local function dbg(text)
    love.graphics.print(text, 4, y)
    y = y + 12
  end

  local cam, mode = self.sistemaTablet:getCamera()

  dbg("FPS: " .. love.timer.getFPS())
  dbg("Timer: " .. string.format("%.2f", self.generalTimer:get()))
  dbg("Mouse (raw): " .. love.mouse.getX() .. ", " .. love.mouse.getY())
  dbg("Mouse (scaled): " .. math.floor(self.mousePos[1]) .. ", " .. math.floor(self.mousePos[2]))
  dbg("Scale: " .. string.format("%.2f", self.currentScale))
  dbg("Offset: " .. math.floor(self.offsetX) .. ", " .. math.floor(self.offsetY))
  dbg("Window: " .. love.graphics.getWidth() .. "x" .. love.graphics.getHeight())
  dbg("Canvas: " .. self.baseWidth .. "x" .. self.baseHeight)
  dbg("Background: " .. math.floor(self.Bck.x) .. ", " .. math.floor(self.Bck.y))
  dbg("Tablet ativo: " .. tostring(self.painel.isOn))
  dbg("Q: alterna debug info")
  dbg("Current Camera/Mode: " .. cam .. ", " .. mode)
  dbg(
    "Duto trancado: " ..
    self.sistemaTablet:getLockedDuct()[1] .. ", " ..
    self.sistemaTablet:getLockedDuct()[2]
  )
  dbg(
    "Meia Timer: " ..
    string.format("%.2f", self.meia.movementOpportunityTimer:get())
  )
end

function Game:draw()
  -- BACKGROUND
  love.graphics.draw(self.Bck.image, self.Bck.x, self.Bck.y)
  
  self.urso:draw()
  self.markoth:draw()
  self.sistemaTablet:drawBottom()
  self.lenny:draw()
  self.meia:draw()
  self.jeffWarzatski:draw()
  self.sistemaTablet:drawTop()
  self.painel:draw()
  self.clock:draw()
  self.randomButton:draw()

  if self.showDebug then
    self:drawDebug()
  end
end

return Game
