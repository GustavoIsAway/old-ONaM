local CollBox = require("scripts.classes.CollisionBox")
local utils = require("scripts.utils")

local Button = {}
Button.__index = Button


function Button.new(x, y, imagePath, callback)
  local self = setmetatable({}, Button)
  
  self.x, self.y = x, y
  self.image = utils.loadImage(imagePath)
  self.width, self.height = self.image:getWidth(), self.image:getHeight()
  
  self.callback = callback or function() end
  self.hovered = false
  self.pressed = false

  self.collision = CollBox.new(x, y, self.width, self.height)
  return self
end



function Button:update(mouseX, mouseY, mousePressed, scale)
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
end



function Button:draw()
  if self.hovered then
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
  else
    love.graphics.setColor(1, 1, 1, 1)
  end

  love.graphics.draw(self.image, self.x, self.y)
  love.graphics.setColor(1, 1, 1, 1)
end


return Button
