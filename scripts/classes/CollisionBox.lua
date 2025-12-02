-- CAIXA RESPONSÁVEL POR REALIZAR COLISÃO
-- POR PADRÃO, É UM RETÂNGULO

local CollBox = {}
CollBox.__index = CollBox



function CollBox.new(x, y, wid, hei)
	local self = setmetatable({}, CollBox)
	self.type = type
	self.x = x
	self.y = y
	self.width = wid
	self.height = hei
	self.isOn = true
	self.color = {0, 160, 0}

	return self
end



function CollBox:checkMouseColl(mouseX, mouseY)
	if self.isOn then
		if (mouseX >= self.x and mouseX <= self.width + self.x) then
			if (mouseY >= self.y and mouseY <= self.height + self.y) then
				return true
			end
		end
	end
	return false
end



function CollBox:enable()
	self.isOn = true
	self.color = {0, 160, 0}
end



function CollBox:disable()
	self.isOn = false
	self.color = {160, 0, 0}
end



function CollBox:isEnable()
	return self.isOn
end



function CollBox:setPos(newX, newY)
	self.x, self.y = newX, newY
end



function CollBox:setDimensions(newWid, newHei)
	self.width, self.height = newWid, newHei
end



function CollBox:draw(alpha)		-- >color< Recebe tabela
 	love.graphics.push("all")
	love.graphics.setColor(
		self.color[1], 
		self.color[2], 
	 	self.color[3], 
	  alpha or 0.5
	)

	love.graphics.rectangle(
		"fill", 
	  self.x, 
		self.y, 
		self.width, 
		self.height, 
		nil, 
		nil, 
		0
	)
	
	love.graphics.pop()
end



return CollBox
