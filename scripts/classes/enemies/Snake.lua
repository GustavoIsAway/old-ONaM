local Timer = require("scripts.classes.Timer")
local utils = require("scripts.utils")

local Snake = {}
Snake.__index = Snake




function Snake.new(x, y, difficulty)
  local self = setmetatable({}, Snake)
  self.x, self.y = x, y                                               -- Posição

  self.difficulty = difficulty                                        -- Dificuldade: um número de 0 a 20

  -- TODO: balancear os valores dos timers
  -- self.movementOpportunityTimer = Timer.new(20 - (difficulty/1.4))
  self.movementOpportunityTimer = Timer.new(5)
  self.killTimer   =              Timer.new(10)                       -- Tempo para esperar antes de realmente atacar o protagonista

  self.state = 1                                                      -- 1 - 2 = neutro; 3 - esperando; 4 - 6 = posições de ataque; 7 = killstate
  self.cameras = {
    {2, 0},
    {0, 0},                                                           -- Sem câmeras quando ele some do laboratório
    {1, 1},
    {4, 1},
    {2, 1},
    {3, 1},
    {0, 0}
  }

  self.numberOfCameras = #self.cameras
  self.visible = false
  self.killPlayer = false
  self.blocked = false

  self.frames           = {}                                          -- Objeto: não deve receber valores pelos seus índices
  self.frames.inCameras = {
    nil,                                                              -- Imagem do Lenny no laboratório de máquinas
    nil,                                                              -- Sprite vazio: Lenny entra nos dutos, mas não aparece
    utils.loadImage("enemies/lenny/drz_center.png"),
    utils.loadImage("enemies/lenny/drz_front.png"),
    utils.loadImage("enemies/lenny/drz_side.png"),                    -- Sprite do lado direito
    utils.loadImage("enemies/lenny/drz_side.png")                     -- Sprite do lado esquerdo
  }
  self.frames.jumpscare = {}                                          -- Frames do jumpscare
  
  self.isOnCamera = false

  return self
end




function Snake:isGonnaMove(min, max)
  local sorted = math.random(min, max)

  if sorted <= self.difficulty then
    return true
  else
    return false
  end

end




function Snake:update(dt, playerCamera, isOn)                        -- playerCamera aqui é a câmera e o modo
  if self.difficulty == 0 then
    return
  end


  self.isOnCamera = (playerCamera[1] == self.cameras[self.state][1] and playerCamera[2] == self.cameras[self.state][2]) and isOn
  self.currentCamera = playerCamera

  if self.state ~= 7 then
    if not self.movementOpportunityTimer:getJammed() then
      self.movementOpportunityTimer:update(dt)
    else
      if self:isGonnaMove(1, 20) then
        if self.state < 3 then
          self.state = self.state + 1
        elseif self.state == 3 then
          self.state = self.state + math.random(1, 3)
        elseif self.state >= 4 and self.state <= 6 then
          if self.blocked then
            self.state = 3
          else
            self.state = 7
          end
        end
      end

      self.movementOpportunityTimer:set(0)
    end
  else
    if not self.killTimer:getJammed() then
      self.killTimer:update(dt)
    else
      self.killPlayer = true
    end
  end

  return self.killPlayer
end




function Snake:draw()
  if self.difficulty == 0 then
    return
  end

  if self.frames.inCameras[self.state] ~= nil and self.isOnCamera and self.state ~= 7 then
    love.graphics.draw(self.frames.inCameras[self.state], self.x, self.y)
  end

  print(self.state)
  
end




return Snake
