local Timer = require("scripts.classes.Timer")
local utils = require("scripts.utils")

local Sock = {}
Sock.__index = Sock




function Sock.new(x, y, difficulty)
  local self = setmetatable({}, Sock)
  self.x, self.y = x, y                                           -- Posição

  self.difficulty = difficulty                                    -- Dificuldade: um número de 0 a 20

  -- TODO: balancear os valores dos timers
  self.movementOpportunityTimer = Timer.new(math.floor(50 - (difficulty/2)))
  self.killTimer                = Timer.new(10)                   -- Tempo para esperar antes de realmente atacar o protagonista

  self.state = 1                                                  -- 1 - Esperando; 2 - Ativo (fora da primeira câmera); 3-5 Na sala; 6 - Killstate; 
  self.cameras = {1, 2, 3, 4, 5}                                  -- Câmeras nas quais ele pode estar

  self.numberOfCameras = #self.cameras
  self.isVisible = true
  self.killPlayer = false
  self.isOnCamera = false
  self.currentCamera = {0, 0}
  self.onlyFrame = utils.loadImage("enemies/meia/peixe.jpg")
  self.cameraOn = false


  self.frames           = {}                                      -- Objeto: não deve receber valores pelos seus índices
  self.frames.inCameras = {
    nil,
    nil,
    nil,
    nil,
  }
  self.frames.jumpscare = {nil}                                   -- Frames do jumpscare


  return self
end




function Sock:isGonnaMove(min, max)
  local sorted = math.random(min, max)

  if sorted <= self.difficulty then
    return true
  end

  return false

end




function Sock:update(dt, playerCamera, isOn, bearStalling)                      -- playerCamera aqui é a câmera e o modo
  if self.difficulty == 0 or bearStalling then
    return false
  end


  self.isOnCamera = (playerCamera[1] == self.cameras[self.state] and playerCamera[2] == 0) and isOn
  self.currentCamera = self.cameras[self.state]
  --self.currentSprite = self.frames.inCameras[self.state]


  -- Comportamento do timer dependendo de como o jogador está com a tela na câmera
  if self.isOnCamera then
    self.movementOpportunityTimer:setMultiplier(0)
  else
    self.movementOpportunityTimer:setMultiplier(1)
  end


  -- Timer rodando
  self.movementOpportunityTimer:update(dt)


  if self.movementOpportunityTimer:isJammed() then
    if self.state < 6 then
      self.state = self.state + 1
      self.movementOpportunityTimer:set(0)
    end
  elseif self.state == 6 then
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


  if self.isOnCamera then
    love.graphics.draw(self.onlyFrame, self.x, self.y)
  end

  
end




return Sock
