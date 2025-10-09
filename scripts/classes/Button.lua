Timer   = require("scripts.classes.Timer")
utils   = require("scripts.utils")
CollBox = require("scripts.classes.CollisionBox")


local Button = {}
Button.__index = Button


function Button.new(x, y, scale, frames)  -- Espera >frames< como tabela
  self = setmetatable({}, Button)
  self.x, self.y = x or 0, y or 0
  self.scale = tonumber(scale) or 1
  self.currentFrame = nil
  self.frames = nil
  self.collisionBox = nil
  self.activateCollision = nil
  
  if (type(frames) == "table") then
    self.frames = frames
    self.currentFrame = 1
    self.collisionBox = CollBox.new(self.x,               -- Pressupões frames de mesmo tamanho
                                    self.y, 
                                    frames[1]:getWidth(), 
                                    frames[1].getHeight()
    )
    self.activateCollision = true
  end
  
  return self
  
end


function Button:update(mouseX, mouseY)
  collided = collisionBox:checkMouseColl(mouseX, mouseY)
  
end


return Entity
