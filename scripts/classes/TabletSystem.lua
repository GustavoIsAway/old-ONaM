local CollBox = require("scripts.classes.CollisionBox")
local Timer = require("scripts.classes.Timer")
local bit = require("bit")


local TabletSystem = {}
TabletSystem.__index = TabletSystem



function TabletSystem.new(screenW, screenH)
  local self = setmetatable({}, TabletSystem)
  self.screenW, self.screenH = screenW, screenH
  self.mapImage = utils.loadImage("mapa.png")
  self.redCircleImage = nil
	self.redCircleState = true                     -- 0 -> Some; 1 -> Aparece;
  self.recordTimer = Timer.new(1)
  self.mode = 0                                  -- 0 -> normal, 1 -> dutos;
  self.stateOfTablet = false
  self.uiCameraButton = utils.loadImage("uiCameraButton.png")
  self.mainCameraButtons = {}
  self.mainCameraButtons.buttonNumber = 3
  self.mainCameraButtons.positions = {}
  self.mainCameraButtons.activeCamera = 1

  self.ductCameraButtons = {}
  self.ductCameraButtons.buttonNumber = 3
  self.ductCameraButtons.positions = {}
  self.ductCameraButtons.activeCamera = 1


  return self
end



function TabletSystem:update(dt, stateOfTablet)
  self.stateOfTablet = stateOfTablet
  if not stateOfTablet then                      -- Apenas atualiza com tablet ligado
    if self.redCircleState then self.redCircleState = false end
    return
  end
  
	self.recordTimer:update(dt)

	if self.recordTimer:getJammed() then
		self.redCircleState = not self.redCircleState
		self.recordTimer:set(0)
	end
end



function TabletSystem:getCamera()
  if (self.mode == 0) then
    return self.mainCameraButtons.activeCamera, self.mode
  else
    return self.ductCameraButtons.activeCamera, self.mode
  end
end



function TabletSystem:draw()
  if not self.stateOfTablet then
    return
  end
  
  if self.redCircleState then
    love.graphics.push()          -- Empilha configurações padrão
    
    love.graphics.setColor(150, 0, 0)
    love.graphics.circle("fill", 50, 45, 15)

    love.graphics.pop()           -- Saca configurações padrão
  end

  love.graphics.draw(self.mapImage, self.screenW - (self.mapImage:getWidth() + 30), 
                     self.screenH - ((self.mapImage:getHeight() + 30)))
end



return TabletSystem
