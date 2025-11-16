local Timer = {}
Timer.__index = Timer

function Timer.new(timeLimit)
  local self = setmetatable({}, Timer)
  
  self.maxTime = timeLimit
  self.count = 0
  self.jammed = false
  self.isPaused = false
  self.valid = nil
  self.timeMultiplier = 1
  if type(self.maxTime) == "number" or self.maxTime == nil then self.valid = true else self.valid = false end

  return self
end



function Timer:setMultiplier(val)
  self.timeMultiplier = val
end



function Timer:set(value)
  self.count = value
  if self.count < self.maxTime then
    self.jammed = false
  else
    self.jammed = true
  end
end



function Timer:setMaxTime(value)
  if type(value) == "number" or value == nil then
    self.valid = true
  else
    self.valid = false
  end
  self.maxTime = value

end



function Timer:get()
  return self.count
end



function Timer:update(dt)
  if not self.isPaused and not self.jammed and self.valid then
    self.count = self.count + (dt * self.timeMultiplier)
    if self.maxTime ~= nil then
      if self.count >= self.maxTime then
        self.jammed = true
      end
    end
  end
end



function Timer:reset()
  self.count = 0
  self.jammed = false
end



function Timer:isJammed()
  return self.jammed
end



return Timer
