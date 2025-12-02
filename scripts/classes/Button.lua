local CollBox = require("scripts.classes.CollisionBox")
local utils = require("scripts.utils")

local Button = {}
Button.__index = Button


function Button.new(x, y, imagePath, text, callback)
  local self = setmetatable({}, Button)
  
  self.x, self.y = x, y

  self.text = nil
  self.textColor = {1, 1 ,1}
  if type(text) == "string" then
    self.text = text
  elseif type(text) == "number" then
    self.text = tostring(text)
  end

  self.image = nil
  if type(imagePath) ~= "nil" then
    self.image = utils.loadImage(imagePath)
    self.width, self.height = self.image:getWidth(), self.image:getHeight()
  end

  self.callback = callback or function() end
  self.hovered  = false
  self.pressed  = false
  self.vanished = false

  self.dragging = false
  self.dragOffsetX = 0
  self.dragOffsetY = 0
  self.activatePrintPos = true

  self.collision = CollBox.new(x, y, self.width, self.height)
  return self
end



function Button:dragWithRightMouse(mouseX, mouseY)
  if self.vanished then return end

  local rightDown = love.mouse.isDown(2)

  -- Começar a arrastar
  if rightDown and not self.dragging then
    if self.collision:checkMouseColl(mouseX, mouseY) then
      self.dragging = true
      self.dragOffsetX = mouseX - self.x
      self.dragOffsetY = mouseY - self.y
    end
  end

  -- Se estiver arrastando, atualizar posição
  if self.dragging then
    if rightDown then
      self.x = mouseX - self.dragOffsetX
      self.y = mouseY - self.dragOffsetY
      self.collision:setPos(self.x, self.y)
    else
      self.dragging = false
    end
  end
end





function Button:update(mouseX, mouseY, mousePressed)
  local isHover = self.collision:checkMouseColl(mouseX, mouseY)
  
  if isHover and not self.hovered then
    self.hovered = true
  elseif not isHover and self.hovered then
    self.hovered = false
  end
  
  if isHover and mousePressed and not self.pressed then
    self.pressed = true
    self.callback()
  elseif not mousePressed then
    self.pressed = false
  end

  self:dragWithRightMouse(mouseX, mouseY)

end



function Button:makeVanish()
  self.collision:disable()
  self.vanished = true
end



function Button:makeAppear()
  self.collision:enable()
  self.vanished = false
end



function Button:didVanish()
  return self.vanished
end



function Button:draw()
  if not self:didVanish() then
    if self.activatePrintPos then
      love.graphics.print("x = " .. tostring(self.x) .. ";" .. "y = " .. tostring(self.y) .. ";",
        self.x,
        self.y - 20
      )
    end
    if self.hovered then
      love.graphics.setColor(0.8, 0.8, 0.8, 1)
    end
  
    love.graphics.draw(self.image, self.x, self.y)
    love.graphics.setColor(1, 1, 1, 1)
  end
end


return Button
