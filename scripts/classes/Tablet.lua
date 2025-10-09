local Entity = require("scripts.classes.Entity")
local utils = require("scripts.utils")
local CollBox = require("scripts.classes.CollisionBox")
local Timer = require("scripts.classes.Timer")


local Tablet = setmetatable({}, { __index = Entity }) -- herda de Entity
Tablet.__index = Tablet



function Tablet.new(screenX, screenY, scale)									 -- Possui x e y herdados de Entity
    local self = setmetatable(Entity.new(0, 0, 1), Tablet) -- chama o construtor do pai
    self.isOn = false
    self.roomCameras = {} 	
    self.ductCameras = {}			-- inicialmente apenas essas
    self.modeSelected = 0			-- Se 0, então roomCameras. Se 1, ductCameras.
    self.tabletDim = {screenX, screenY}
    self.cameraSelected = 0
    self.frames = {
    	utils.loadImage("pannel/1.png"),
    	utils.loadImage("pannel/2.png"),
    	utils.loadImage("pannel/3.png"),
    	utils.loadImage("pannel/4.png"),
    	utils.loadImage("pannel/5.png"),
    	utils.loadImage("pannel/6.png"),    	
    }
    self.currentFrame = 0
		self.isMoving = false
		self.animation = -1
		self.animTimer = Timer.new(0.025)

		self.Button = {}
		self.Button.x, self.Button.y = 150, 565
		self.Button.frames = {
			utils.loadImage("botaoPrincipal.png")
		} 	-- 2 frames (CIMA, BAIXO)
		self.Button.collision = CollBox.new(self.Button.x, 
																				self.Button.y,
																				self.Button.frames[1]:getWidth(),
																				screenY - self.Button.y)
		self.Button.intouchable = false
		self.Button.activated = false
    self.Button.mouseOn = false
		
    
    return self
end



function Tablet:update(dt, mouseX, mouseY)
	-- == BUTTON UPDATE ==

	-- Detecta se o mouse está sobre o botão
	local mainButtonCollision = self.Button.collision:checkMouseColl(mouseX, mouseY)

	-- Verifica se o tablet terminou animação
	local animFinished = (self.currentFrame == 0 or self.currentFrame == 6)

	-- Atualiza estado do botão (hover)
	if mainButtonCollision then
		-- se mouse entrou agora
		if not self.Button.mouseOn then
			self.Button.mouseOn = true
			-- só pode ativar se:
			-- 1. terminou animação anterior
			-- 2. não está se movendo
			-- 3. mouse acabou de entrar no botão
			if animFinished and not self.isMoving then
				self.Button.activated = true
			else
				self.Button.activated = false
			end
		else
			self.Button.activated = false -- mouse continua em cima, não dispara
		end
	else
		-- mouse saiu do botão
		self.Button.mouseOn = false
		self.Button.activated = false
	end


	-- Se o botão foi ativado, alterna a animação
	if self.Button.activated then
		self.isMoving = true
		-- define direção da animação:
		-- se estava fechado, abre (+1)
		-- se estava aberto, fecha (-1)
		self.animation = (self.currentFrame == 0) and 1 or -1
	end


	-- == TABLET ANIMATION UPDATE ==
	if self.isMoving then
		self.animTimer:update(dt)
	
		if self.animTimer:getJammed() then
			self.currentFrame = self.currentFrame + self.animation
			self.animTimer:reset()
	
			if self.currentFrame >= 6 then
				self.currentFrame = 6
				self.isMoving = false
			elseif self.currentFrame <= 0 then
				self.currentFrame = 0
				self.isMoving = false
			end
		end
	end

	self.isOn = (self.currentFrame == 6)
	
end



function Tablet:getTabletState()
	return self.isOn
end



function Tablet:draw()
	if self.currentFrame > 0 then
		love.graphics.draw(self.frames[self.currentFrame], self.x, self.y)
	end

	love.graphics.draw(self.Button.frames[1], self.Button.x, self.Button.y)
end



return Tablet
