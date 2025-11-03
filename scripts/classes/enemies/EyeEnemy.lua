local Timer = require("scripts.classes.Timer")
local utils = require("scripts.utils")

local EyeEnemy = {}
EyeEnemy.__index = EyeEnemy




function EyeEnemy.new(x, y, difficulty)
  local self = setmetatable({}, EyeEnemy)
  self.x, self.y = x, y                     -- Posição

  self.difficulty = difficulty              -- Dificuldade: um número de 0 a 20

  -- TODO: balancear os valores dos timers
  -- self.movementOpportunityTimer = Timer.new(20 - (difficulty/1.4))
  self.movementOpportunityTimer = Timer.new(5)
  self.attackTimer =              Timer.new(12 - (difficulty/4))     -- Tempo para permanecer no estado de ataque, antes de entrar no kill state
  self.killTimer   =              Timer.new(5)                       -- Tempo para esperar antes de realmente atacar o protagonista
  self.watchTimer  =              Timer.new(3 + (difficulty/6.5))

  self.state = 0                            -- 0 = inativo; 1 = nas câmeras; 2 = killstate
  self.camera = 0                           -- Camera 0 inicialmente, que não existe
  self.numberOfCameras = 3
  self.visible = false
  self.killPlayer = false

  self.frames           = {}                -- Objeto: não deve receber valores pelos seus índicies
  self.frames.inCameras = utils.loadImage(  -- Sprite do Jeff nas câmeras
    "enemies/jeff_warzatski/stillImage.png"
  )
  self.frames.jumpscare  = {}               -- Frames do jumpscare
  self.isOnCamera = false
  self.currentCamera = nil

  return self
end




function EyeEnemy:isGonnaMove(min, max)               -- Retorna verdade sempre que sorteio <= dificuldade
  local sorted = math.random(min, max)

  if sorted <= self.difficulty then
    return true
  else
    return false
  end

end




function EyeEnemy:update(dt, playerCamera, isOn)
  if self.difficulty == 0 then
    return
  end

  self.isOnCamera = (playerCamera[1] == self.camera) and isOn
  self.currentCamera = playerCamera

  -- ?? Mecânica de sorteio para aparecer nas cameras
  if self.state == 0 then
    if not self.movementOpportunityTimer:getJammed() then
      self.movementOpportunityTimer:update(dt)
    else
      local moving = self:isGonnaMove(1, 20)
      if moving == true then
        self.state = 1
        self.camera = math.random(1, self.numberOfCameras)
        self.attackTimer:set(0)
        self.watchTimer:set(0)
      end
      self.movementOpportunityTimer:set(0)
    end
  end

  -- ?? Mecânica do tempo de espera nas cameras
  if self.state == 1 then
    if not self.attackTimer:getJammed()then
      if not self.isOnCamera then
        self.attackTimer:update(dt)
        self.visible = false
      else
        if not self.watchTimer:getJammed() then
          self.watchTimer:update(dt)
        else
          self.state = 0
          self.camera = 0
          self.movementOpportunityTimer:set(0)
        end
        self.visible = true
      end
    else
      self.state = 2
      self.camera = 0
      self.visible = false
    end
  end


  -- ?? Mecânica de kill
  if self.state == 2 then
    if not self.killTimer:getJammed() then
      self.killTimer:update(dt)
    else
      self.killPlayer = true
    end
  end

  return self.killPlayer


end




function EyeEnemy:draw()
  if self.difficulty == 0 then
    return
  end

  if self.visible == true and self.currentCamera[2] == 0 and self.isOnCamera and self.camera > 0 then
    love.graphics.draw(self.frames.inCameras, self.x, self.y)
  end
end




return EyeEnemy
