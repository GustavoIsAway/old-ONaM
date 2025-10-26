local Timer = {}
Timer.__index = Timer

function Timer.new(waitTime)
  local self = setmetatable({}, Timer)
  self.waitTime = waitTime
  self.count = 0
  self.jammed = false
  self.isPaused = false
  self.valid = nil
  if type(self.waitTime) == "number" or self.waitTime == nil then self.valid = true else self.valid = false end
  return self
end



function Timer:set(value)
  self.count = value
  if self.count < self.waitTime then
    self.jammed = false
  else
    self.jammed = true
  end
end



function Timer:changeWaitTimer(value)
  if type(value) == "number" or value == nil then
    self.valid = true
  else
    self.valid = false
  end
  self.waitTime = value

end



function Timer:get()
  return self.count
end



function Timer:update(dt)
  if not self.isPaused and not self.jammed and self.valid then
    self.count = self.count + dt
    if self.waitTime ~= nil then
      if self.count >= self.waitTime then
        self.jammed = true
      end
    end
  end
end



function Timer:pause()
  self.isPaused = true
end



function Timer:unpause()
  self.isPaused = false
end



function Timer:reset()
  self.count = 0
  self.jammed = false
end



function Timer:getJammed()
  return self.jammed
end



return Timer
