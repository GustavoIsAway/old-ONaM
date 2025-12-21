local Timer = require("scripts.classes.Timer")
local utils = require("scripts.utils")

local EyeEnemy = {}
EyeEnemy.__index = EyeEnemy




function EyeEnemy.new(x, y, difficulty)
  local self = setmetatable({}, EyeEnemy)
  self.x, self.y = x, y                     -- Posição

  self.difficulty = difficulty              -- Dificuldade: um número de 0 a 20

  -- TODO: balancear os valores dos timers
  self.movementOpportunityTimer = Timer.new(12)
  self.attackTimer =              Timer.new(14 - (difficulty/5))     -- Tempo para permanecer no estado de ataque, antes de entrar no kill state
  self.killTimer   =              Timer.new(05)                       -- Tempo para esperar antes de realmente atacar o protagonista
  self.watchTimer  =              Timer.new(1.4 + (difficulty/12))

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
  self.drawCurrentSprite = nil

  return self
end




function EyeEnemy:isGonnaMove(min, max)               -- Retorna verdade sempre que sorteio <= dificuldade
  local sorted = math.random(min, max)

  if sorted <= self.difficulty then
    return true
  end
  
  return false

end




function EyeEnemy:update(dt, playerCamera, isOn, bearStalling)
  if self.difficulty == 0 or bearStalling then return false end

  self.isOnCamera = (playerCamera[1] == self.camera) and isOn
  self.currentCamera = playerCamera

  -- Estados
  if self.state == 0 then
    if not self.movementOpportunityTimer:isJammed() then
      self.movementOpportunityTimer:update(dt)
    else
      if self:isGonnaMove(1, 20) then
        -- salva os valores mas não aplica ainda
        self.nextState  = 1
        self.nextCamera = math.random(1, self.numberOfCameras)
        self.pendingMove = true
      end
      self.movementOpportunityTimer:set(0)
    end
  end

  -- Aplica a troca só quando ele não está sendo visto
  if self.pendingMove and not self.isOnCamera then
    self.state  = self.nextState
    self.camera = self.nextCamera
    self.attackTimer:set(0)
    self.watchTimer:set(0)
    self.pendingMove = false
  end

  -- Mecânica de tempo nas câmeras
  if self.state == 1 then
    if not self.attackTimer:isJammed() then
      if not self.isOnCamera then
        self.attackTimer:update(dt)
        self.visible = false
      else
        if not self.watchTimer:isJammed() then
          self.watchTimer:update(dt)
        else
          -- Sai da câmera
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

  -- Atualiza função de desenho
  if self.visible and self.currentCamera[2] == 0 and self.isOnCamera and self.camera > 0 then
    self.drawCurrentSprite = function()
      love.graphics.draw(self.frames.inCameras, self.x, self.y)
    end
  else
    self.drawCurrentSprite = function() end
  end

  -- Kill
  if self.state == 2 then
    if not self.killTimer:isJammed() then
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

  self.drawCurrentSprite()

end




return EyeEnemy
