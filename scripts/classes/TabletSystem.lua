local CollBox = require("scripts.classes.CollisionBox")
local Timer = require("scripts.classes.Timer")
local Button = require("scripts.classes.Button")
local utils = require("scripts.utils")
local bit = require("bit")

local TabletSystem = {}
TabletSystem.__index = TabletSystem



function TabletSystem.new(screenW, screenH)
  local self = setmetatable({}, TabletSystem)
  self.screenW, self.screenH = screenW, screenH
  self.mapImage = utils.loadImage("mapa.png")
  self.mapGap = 90
  self.redCircleState = true
  self.recordTimer = Timer.new(1)
  self.mode = 0                                  -- 0 -> Normal; 1 -> Dutos;
  self.cameraProgressInterval = Timer.new(0.1)
  self.cameraProgress = 50
  
  self.stateOfTablet = false

  -- == Câmeras ==
  self.mainCameraImages = {
    utils.loadImage("cameras/main1.png"),
    utils.loadImage("cameras/main2.png"),
    utils.loadImage("cameras/main3.png")
  }

  self.ductCameraImages = {
    utils.loadImage("cameras/duct1p.png"),
    utils.loadImage("cameras/duct1.png"),
    utils.loadImage("cameras/duct2.png"),
    utils.loadImage("cameras/duct3.png")
  }
  
  -- == Câmeras Ativas de Cada Modo ==
  self.mainactiveCamera = 1
  self.ductactiveCamera = 1

  -- == Botões ==
  self.buttons = {
    Button.new(screenW - 120, 40, "uiButtonNext.png", function()
      if self.mode == 0 then
        self.mainactiveCamera = (self.mainactiveCamera % #self.mainCameraImages) + 1
      else
        self.ductactiveCamera = (self.ductactiveCamera % #self.ductCameraImages) + 1
      end
      self.cameraProgress = 50
    end),

    Button.new(screenW - 120, 100, "uiButtonMode.png", function()
      self.mode = bit.bxor(self.mode, 1)
    end)
  }
  self.cameraProgressBarWidth = self.buttons[1].image:getWidth()
  self.cameraProgressParts = 50


  return self
end



function TabletSystem:update(dt, mouseX, mouseY, stateOfTablet)
  self.stateOfTablet = stateOfTablet
  if not stateOfTablet then
    if self.redCircleState then self.redCircleState = false end
    return
  end

  self.recordTimer:update(dt)
  self.cameraProgressInterval:update(dt)

  if self.recordTimer:getJammed() then
    self.redCircleState = not self.redCircleState
    self.recordTimer:set(0)
  end

  if self.cameraProgressInterval:getJammed() then
    self.cameraProgress = self.cameraProgress - 1
    self.cameraProgressInterval:set(0)
  end

  if self.cameraProgress == 0 then
    if self.mode == 0 then
      self.mainactiveCamera = (self.mainactiveCamera % #self.mainCameraImages) + 1
    else
      self.ductactiveCamera = (self.ductactiveCamera % #self.ductCameraImages) + 1
    end
    self.cameraProgress = 50
  end

  local mousePressed = love.mouse.isDown(1)

  for _, btn in ipairs(self.buttons) do
    btn:update(mouseX, mouseY, mousePressed)
  end
end



function TabletSystem:getCamera()
  if (self.mode == 0) then
    return self.mainactiveCamera, self.mode
  else
    return self.ductactiveCamera, self.mode
  end
end



function TabletSystem:draw()
  if not self.stateOfTablet then
    return
  end

  -- Imagem da câmera ativa
  local activeCamera, mode = self:getCamera()
  local camImage
  if mode == 0 then
    camImage = self.mainCameraImages[activeCamera]
  else
    camImage = self.ductCameraImages[activeCamera]
  end

  love.graphics.draw(camImage, 0, 0)

  -- Botões
  for _, btn in ipairs(self.buttons) do
    btn:draw()
  end
  
  -- Indicador de gravação
  if self.redCircleState then
    love.graphics.push("all")
    love.graphics.setColor(150, 0, 0)
    love.graphics.circle("fill", 50, 45, 15)
    love.graphics.pop()
  end

  -- Mapa
  love.graphics.draw(
    self.mapImage,
    self.screenW - (self.mapImage:getWidth() + self.mapGap),
    self.screenH - (self.mapImage:getHeight() + self.mapGap),
    0,
    1.2,
    1.2
  )

  -- Barra de Progresso da Câmera (TODO)
  love.graphics.rectangle("fill", self.screenW - 120, 160, self.cameraProgress * (self.cameraProgressBarWidth / self.cameraProgressParts), 10)

end



return TabletSystem
