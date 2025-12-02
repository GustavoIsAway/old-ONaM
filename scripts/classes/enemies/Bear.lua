local Timer = require("scripts.classes.Timer")
local utils = require("scripts.utils")

local Bear = {}
Bear.__index = Bear




function Bear.new(x, y, difficulty)
  local self = setmetatable({}, Bear)
  self.x, self.y = x, y                     -- Posição
  self.difficulty = difficulty              -- Dificuldade: um número de 0 a 20

  -- TODO: balancear os valores dos timers
  self.movementOpportunityTimer = Timer.new(16)
  self.waitTimer                = Timer.new(12 - (difficulty/3.9))
  self.attackTimer =              Timer.new(13 - (difficulty/5))      -- Tempo para permanecer no estado de ataque, antes de entrar no kill state
  self.killTimer   =              Timer.new(05)                       -- Tempo para esperar antes de realmente atacar o protagonista

  self.state = 0                            -- 0 = sentado; 1 - 3 = chegando; 4 - ataque; 5 - killState
  self.visible = true
  self.killPlayer = false
  
  self.stall = false                        -- Quando ele ataca, ele dá stall nos outros personagens.
  self.attckPosition = {0, 0}               -- {side, relativePosition} --> (Side é o lado em que ele ataca
                                            -- (esquerda, direita ou meio) e relativePosition é uma das posições
                                            -- de ataque nesse lado.)
  self.mouseCollision = false

  self.frames           = {}                -- Objeto: não deve receber valores pelos seus índicies
  self.frames.inCameras = {
    nil,                                    -- Sentado
    nil,                                    -- Desaparecido
    nil,                                    -- Atacando
  }

  self.frames.jumpscare  = {}               -- Frames do jumpscare
  self.isOnCamera = false
  self.currentSprite = nil

  return self
end




function Bear:isGonnaMove(min, max)               -- Retorna verdade sempre que sorteio <= dificuldade
  local sorted = math.random(min, max)

  if sorted <= self.difficulty then
    return true
  end

  return false

end




function Bear:update(dt, mousePos, isOn)                    -- Retorna uma tupla {self.killPlayer, self.stall}
  if self.difficulty == 0 then return {nil, nil} end

  self.isLookingAtOffice = not isOn



  return {self.killPlayer, self.stall}
end





function Bear:draw()
  if self.difficulty == 0 then
    return
  end

  
end




return Bear
