local Entity = require("scripts.classes.Entity")
local utils = require("scripts.utils")
local CollBox = require("scripts.classes.CollisionBox")
local Timer = require("scripts.classes.Timer")


local TabletSystem = {}
TabletSystem.__index = TabletSystem



function TabletSystem.new()
	local self = setmetatable({}, TabletSystem)
	self.canvas = love.graphics.newCanvas(760, 560)
	

	return self	
end
