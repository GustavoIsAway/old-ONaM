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
  self.floorMap = utils.loadImage("mapa.png")
  self.ventsMap = utils.loadImage("mapaDutos.png")
  self.mapGap = 90
  self.redCircleState = true
  self.recordTimer = Timer.new(1)
  self.mode = 0                                  -- 0 -> Normal; 1 -> Dutos;
  self.modePrevious = self.mode
  self.stateOfTablet = false                     -- Diz se o tablet está ligado ou desligado
  self.lockedDuct = {0, 1}

  self.buttonsFloorPositions = {
    {735, 474},
    {597, 319},
    {548, 446},
    {441, 379}
  }

  self.buttonsVentPositions = {
    {668, 419},
    {725, 385},
    {667, 459},
    {543, 409}
  }

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
    Button.new(self.buttonsFloorPositions[1][1], self.buttonsFloorPositions[1][2], "uiButton1.png", "CAM 1", "circle", function()
      if self.mode == 0 then
      self.mainActiveCamera = 1
      else
      self.ductsActiveCamera = 1
      end
    end),
    Button.new(self.buttonsFloorPositions[2][1], self.buttonsFloorPositions[2][2], "uiButton2.png", "CAM 2", "circle", function()
      if self.mode == 0 then
      self.mainActiveCamera = 2
      else
      self.ductsActiveCamera = 2
      end
    end),
    Button.new(self.buttonsFloorPositions[3][1], self.buttonsFloorPositions[3][2], "uiButton3.png", "CAM 3", "circle", function()
      if self.mode == 0 then
      self.mainActiveCamera = 3
      else
      self.ductsActiveCamera = 3
      end
    end),
    Button.new(self.buttonsFloorPositions[4][1], self.buttonsFloorPositions[4][2], "uiButton4.png", "CAM 4", "circle", function()
      if self.mode == 0 then
      self.mainActiveCamera = 4
      else
      self.ductsActiveCamera = 4
      end
    end),
    Button.new(680, 220, "uiButtonMode.png", nil, "rect", function()
      self.mode = bit.bxor(self.mode, 1)
    end)
  }

  self.ventButtons = {}

  self.uiButtonLock = Button.new(screenW - 120, 180, "uiButtonLock.png", nil, "rect", function()
      if self.mode == 1 then
        if self.ductsActiveCamera ~= 1 then
          if self.lockedDuct[1] ~= self.ductsActiveCamera then
            self.lockedDuct = {self.ductsActiveCamera, 1}
          else
            self.lockedDuct = {0, 1}
          end
        end
      end
    end
  )

  -- == Barra de Progresso ==
  self.mainActiveCamera = 1
  self.ductsActiveCamera = 1

  return self
end




function TabletSystem:update(dt, mouseX, mouseY, mouseInputState, stateOfTablet)
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
  
  local mousePressed = mouseInputState[1]

  
  self.uiButtonLock:update(mouseX, mouseY, mousePressed)

  for _, btn in ipairs(self.baseButtons) do
    btn:update(mouseX, mouseY, mousePressed)
  end

  if self.mode == 1 and self.ductsActiveCamera ~= 1 then
    self.uiButtonLock:makeAppear()
  else
    self.uiButtonLock:makeVanish()
  end

  if self.mode ~= self.modePrevious then
    if self.mode == 1 then
      for i = 1, #self.baseButtons - 1, 1 do
        local btn = self.baseButtons[i]
        btn:setPos(unpack(self.buttonsVentPositions[i]))
      end
    end

    if self.mode == 0 then
      for i = 1, #self.baseButtons - 1, 1 do
        local btn = self.baseButtons[i]
        btn:setPos(unpack(self.buttonsFloorPositions[i]))
      end
    end
  end

  self.modePrevious = self.mode
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




function TabletSystem:drawBottom()
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

end



function TabletSystem:drawTop()
  if not self.stateOfTablet then
    return
  end

  -- Indicador de gravação
  if self.redCircleState then
    love.graphics.push("all")
    love.graphics.setColor(150, 0, 0)
    love.graphics.circle("fill", 50, 45, 15)
    love.graphics.pop()
  end

  -- Mapa
  love.graphics.draw(         -- Mapa do solo
    self.floorMap,
    self.screenW - (self.floorMap:getWidth() + self.mapGap),
    self.screenH - (self.floorMap:getHeight() + self.mapGap),
    0,
    1.2,
    1.2
  )

  if self.mode == 1 then
    love.graphics.draw(         -- Mapa da ventilação
      self.ventsMap,
      self.screenW - (self.floorMap:getWidth() + self.mapGap),
      self.screenH - (self.floorMap:getHeight() + self.mapGap),
      0,
      1.2,
      1.2
    )
  end

  -- Botões do solo
  for _, btn in ipairs(self.baseButtons) do
    btn:draw()
  end


  self.uiButtonLock:draw()

end


return TabletSystem
