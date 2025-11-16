local Timer = require("scripts.classes.Timer")
local utils = require("scripts.utils")

local Sock = {}
Sock.__index = Sock




function Sock.new(x, y, difficulty)
  local self = setmetatable({}, Sock)
  self.x, self.y = x, y                                           -- Posição

  self.difficulty = difficulty                                    -- Dificuldade: um número de 0 a 20

  -- TODO: balancear os valores dos timers
  self.movementTimer            = Timer.new(35)
  self.killTimer                = Timer.new(10)                   -- Tempo para esperar antes de realmente atacar o protagonista

  self.state = 1                                                  -- 1 - Esperando; 2 - Ativo (fora da primeira câmera); 3-5 Na sala; 6 - Killstate; 
  self.cameras = {1, 2, 3, 4, 5}                                  -- Câmeras nas quais ele pode estar

  self.numberOfCameras = #self.cameras
  self.isVisible = true
  self.killPlayer = false
  self.isOnCamera = false
  self.currentCamera = {0, 0}



  self.frames           = {}                                      -- Objeto: não deve receber valores pelos seus índices
  self.frames.inCameras = {
    "f1",
    "f2",
    "f3",
    "f4",
    "f5"
  }
  self.frames.jumpscare = {nil}                                   -- Frames do jumpscare


  return self
end




function Sock:isGonnaMove(min, max)
  local sorted = math.random(min, max)

  if sorted <= self.difficulty then
    return true
  else
    return false
  end

end




function Sock:update(dt, playerCamera, isOn)                      -- playerCamera aqui é a câmera e o modo
  if self.difficulty == 0 then
    return
  end
  
  self.isOnCamera = (playerCamera[1] == self.cameras[self.state][1] and playerCamera[2] == self.cameras[self.state][2]) and isOn
  self.currentCamera = self.cameras[self.state]
  self.currentSprite = self.frames.inCameras[self.state]
  

  -- Comportamento do timer dependendo se o jogador está com a tela na câmera
  if playerCamera[1] == self.cameras[self.state][1] and playerCamera[2] == self.cameras[self.state][2] then
    if isOn then
      self.movementOpportunityTimer:setMultiplier(0)
    else
      self.movementOpportunityTimer:setMultiplier(0.4)
    end
  else
    self.movementOpportunityTimer:setMultiplier(1)
  end

  
  self.movementOpportunityTimer:update(dt)


  if self.movementOpportunityTimer:isJammed() then
    if self.state < 6 then
      self.state = self.state + 1
      self.movementOpportunityTimer:set(0)
    end
  end

  if self.state == 6 then
    self.killTimer:update()
    if self.killTimer:isJammed() then
      self.killPlayer = true
    end
  end
  
  return self.killPlayer
end




function Sock:draw()
  if self.difficulty == 0 then
    return
  end

  if self.isOnCamera and self.state ~= 7 and self.frames.inCameras[self.state] ~= nil then
  end
  
end




return Sock
