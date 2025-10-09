--  SUPERCLASSE PARA CRIAÇÃO DE ENTIDADES
--  COM CARACTERÍSTICAS GERAIS

Timer = require("scripts.classes.Timer")
utils = require("scripts.utils")
CollBox = require("scripts.classes.CollisionBox")

local Entity = {}
Entity.__index = Entity


function Entity.new(x, y, scale)
  self = setmetatable({}, Entity)
  self.x, self.y = x or 0, y or 0
  self.scale = tonumber(scale) or 1
  self.frames = {}
  self.currentFrame = 1
  return self
end


return Entity
