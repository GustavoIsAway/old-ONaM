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
  self.stateOfTablet = false                     -- Diz se o tablet está ligado ou desligado
  self.lockedDuct = {0, 1}

  -- == Câmeras ==
  self.mainCameraImages = {
    utils.loadImage("cameras/main1.png"),
    utils.loadImage("cameras/main2.png"),
    utils.loadImage("cameras/main3.png"),
    nil
  }

  self.ductsCameraImages = {
    utils.loadImage("cameras/duct1p.png"),
    utils.loadImage("cameras/duct1.png"),
    utils.loadImage("cameras/duct2.png"),
    utils.loadImage("cameras/duct3.png")
  }
  
  -- == Câmeras Ativas de Cada Modo ==

  -- == Botões ==
  self.baseButtons = {
    Button.new(screenW - 120, 40, "uiButton1.png", "CAM 1", function()
      self.mainActiveCamera = 1
    end),
    Button.new(screenW - 210, 40, "uiButton2.png", "CAM 2", function()
      self.mainActiveCamera = 2
    end),
    Button.new(screenW - 300, 40, "uiButton3.png", "CAM 3", function()
      self.mainActiveCamera = 3
    end),
    Button.new(screenW - 390, 40, "uiButton4.png", "CAM 3", function()
      self.mainActiveCamera = 4
    end),
    Button.new(screenW - 120, 140, "uiButtonMode.png", nil, function()
      self.mode = bit.bxor(self.mode, 1)
    end)
  }

  self.ventButtons = {}

  self.uiButtonLock = Button.new(screenW - 120, 180, "uiButtonLock.png", nil, function()
      if self.mode == 1 then
        if self.ductsActiveCamera ~= 1 then
          if self.lockedDuct[1] ~= self.ductsActiveCamera then
            self.lockedDuct = {self.ductsActiveCamera, 1}
          else
            self.lockedDuct = {0, 1}
          end
        end
      end
    end)

  -- == Barra de Progresso ==
  self.mainActiveCamera = 1
  self.ductsActiveCamera = 1

  return self
end




function TabletSystem:update(dt, mouseX, mouseY, stateOfTablet)
  self.stateOfTablet = stateOfTablet


  self.recordTimer:update(dt)

  if self.stateOfTablet then
    if self.mode == 0 then
      -- todo
    else
      -- todo
    end
  end

  if not stateOfTablet then
    if self.redCircleState then self.redCircleState = false end
    return
  end

  if self.recordTimer:isJammed() then
    self.redCircleState = not self.redCircleState
    self.recordTimer:set(0)
  end
  
  local mousePressed = love.mouse.isDown(1)

  for _, btn in ipairs(self.baseButtons) do
    btn:update(mouseX, mouseY, mousePressed)
  end
  
  self.uiButtonLock:update(mouseX, mouseY, mousePressed)

  if self.mode == 1 and self.ductsActiveCamera ~= 1 then
    self.uiButtonLock:makeAppear()
  else
    self.uiButtonLock:makeVanish()
  end
end




function TabletSystem:getCamera()
  if (self.mode == 0) then
    return self.mainActiveCamera, self.mode
  else
    return self.ductsActiveCamera, self.mode
  end
end




function TabletSystem:getLockedDuct()
  return self.lockedDuct
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

  if camImage ~= nil then
    love.graphics.draw(camImage, 0, 0)
  else
    love.graphics.push("all")
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", 0, 0, 800, 600)
    love.graphics.pop()
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

  -- Botões do solo
  for _, btn in ipairs(self.baseButtons) do
    btn:draw()
  end

  -- Botões da ventilação
  --[[
  for _, btn in ipairs(self.ventbaseButtons) do
    ventbaseButtons:draw()
  end
  ]]

  self.uiButtonLock:draw()

end



return TabletSystem
