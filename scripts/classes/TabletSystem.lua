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
  self.cameraProgressParts = 40
  self.stateOfTablet = false                     -- Diz se o tablet está ligado ou desligado

  -- == Câmeras ==
  self.mainCameraImages = {
    utils.loadImage("cameras/main1.png"),
    utils.loadImage("cameras/main2.png"),
    utils.loadImage("cameras/main3.png")
  }

  self.ductsCameraImages = {
    utils.loadImage("cameras/duct1p.png"),
    utils.loadImage("cameras/duct1.png"),
    utils.loadImage("cameras/duct2.png"),
    utils.loadImage("cameras/duct3.png")
  }
  
  -- == Câmeras Ativas de Cada Modo ==

  -- == Botões ==
  self.buttons = {
    Button.new(screenW - 120, 40, "uiButtonNext.png", function()
      if self.mode == 0 then
        self.mainActiveCamera = (self.mainActiveCamera % #self.mainCameraImages) + 1
        self.mainCameraProgress = self.cameraProgressParts
      else
        self.ductsActiveCamera = (self.ductsActiveCamera % #self.ductsCameraImages) + 1
        self.ductsCameraProgress = self.cameraProgressParts
      end
    end),

    Button.new(screenW - 120, 100, "uiButtonMode.png", function()
      self.mode = bit.bxor(self.mode, 1)
    end)
  }

  -- == Barra de Progresso ==
  self.cameraProgressBarWidth = self.buttons[1].image:getWidth()

  self.mainActiveCamera = 1
  self.ductsActiveCamera = 1

  self.mainCameraProgressInterval = Timer.new(0.1)
  self.mainCameraProgress = self.cameraProgressParts
  
  self.ductsCameraProgressInterval = Timer.new(0.1)
  self.ductsCameraProgress = self.cameraProgressParts

  return self
end



function TabletSystem:update(dt, mouseX, mouseY, stateOfTablet)
  self.stateOfTablet = stateOfTablet
  incrementParcel = dt * 1.8;

  self.recordTimer:update(dt)
  
  if self.stateOfTablet then
    if self.mode == 0 then
      self.mainCameraProgressInterval:update(dt)
    else
      self.ductsCameraProgressInterval:update(dt)
    end

  else

    if self.mainCameraProgress <= self.cameraProgressParts then
      self.mainCameraProgress = self.mainCameraProgress + incrementParcel
    end

    if self.ductsCameraProgress <= self.cameraProgressParts then
      self.ductsCameraProgress = self.ductsCameraProgress + incrementParcel
    end

  end

  if self.mainCameraProgressInterval:getJammed() then
    self.mainCameraProgress = self.mainCameraProgress - 1
    self.mainCameraProgressInterval:set(0)
  end

  if self.ductsCameraProgressInterval:getJammed() then
    self.ductsCameraProgress = self.ductsCameraProgress - 1
    self.ductsCameraProgressInterval:set(0)
  end

  if self.mainCameraProgress <= 0 then
    self.mainActiveCamera = (self.mainActiveCamera % #self.mainCameraImages) + 1
    self.mainCameraProgress = self.cameraProgressParts
  end

  if self.ductsCameraProgress <= 0 then
    self.ductsActiveCamera = (self.ductsActiveCamera % #self.ductsCameraImages) + 1
    self.ductsCameraProgress = self.cameraProgressParts
  end

  if not stateOfTablet then
    if self.redCircleState then self.redCircleState = false end
    return
  end

  if self.recordTimer:getJammed() then
    self.redCircleState = not self.redCircleState
    self.recordTimer:set(0)
  end
  
  local mousePressed = love.mouse.isDown(1)

  for _, btn in ipairs(self.buttons) do
    btn:update(mouseX, mouseY, mousePressed)
  end
end



function TabletSystem:getCamera()
  if (self.mode == 0) then
    return self.mainActiveCamera, self.mode
  else
    return self.ductsActiveCamera, self.mode
  end
end



function TabletSystem:draw()
  if not self.stateOfTablet then
    return
  end

  -- Imagem da câmera ativa
  if self.mode == 0 then
    camImage = self.mainCameraImages[self.mainActiveCamera]
  else
    camImage = self.ductsCameraImages[self.ductsActiveCamera]
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
  if self.mode == 0 then
    love.graphics.rectangle("fill", self.screenW - 120, 160, self.mainCameraProgress * (self.cameraProgressBarWidth / self.cameraProgressParts), 10)
  else
    love.graphics.rectangle("fill", self.screenW - 120, 160, self.ductsCameraProgress * (self.cameraProgressBarWidth / self.cameraProgressParts), 10)
  end

end



return TabletSystem
