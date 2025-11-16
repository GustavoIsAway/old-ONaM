local Timer = require("scripts.classes.Timer")
local utils = require("scripts.utils")

local Clock = {}
Clock.__index = Clock


function Clock.new(x, y)
  local self = setmetatable({}, Clock)
  self.time = Timer.new(60)
  self.count = 12
  self.period = "AM"
  self.x, self.y = x, y
  self.clockFont = love.graphics.newFont(22)

  return self
end

function Clock:update(dt)
  self.time:update(dt)
  if self.time:isJammed() then
    if self.count == 12 and self.period == "AM" then
      self.period = "PM"
      self.count = 1
    else
      self.count = self.count + 1
    end
    self.time:set(0)
  end
end


function Clock:draw()
  love.graphics.push("all")
  love.graphics.setFont(self.clockFont)
  love.graphics.print(self.count .. " " ..self.period, self.x, self.y)
  love.graphics.pop()


end

return Clock
