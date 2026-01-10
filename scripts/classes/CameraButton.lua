Timer   = require("engine.Timer")
utils   = require("engine.utils")
CollBox = require("engine.CollisionBox")


local CameraButton = {}
CameraButton.__index = CameraButton


function CameraButton.new(x, y, scale, frames)                  -- Espera >frames< como tabela
  self = setmetatable({}, CameraButton)
  self.x, self.y = x or 0, y or 0
  self.scale = tonumber(scale) or 1
  self.currentFrame = nil
  self.frames = nil
  self.collisionBox = nil
  self.activateCollision = nil
  
  if (type(frames) == "table") then
    self.frames = frames
    self.currentFrame = 1
    self.collisionBox = CollBox.new(
      self.x,                                                   -- Pressupõe frames de mesmo tamanho
      self.y, 
      frames[1]:getWidth(),
      frames[1].getHeight()
    )
    self.activateCollision = true
  end
  
  return self
  
end


function CameraButton:update(mouseX, mouseY)
  collided = self.collisionBox:checkMouseColl(mouseX, mouseY)
end


return CameraButton
