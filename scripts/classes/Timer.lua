local Timer = {}
Timer.__index = Timer

function Timer.new(waitTime)
  local self = setmetatable({}, Timer)
  self.waitTime = waitTime
  self.count = 0
  self.jammed = false
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


function Timer:reset()
  Timer:set(0)
end


function Timer:get()
  return self.count
end

function Timer:update(dt)
  if not self.jammed then
    self.count = self.count + dt
    if self.count >= self.waitTime then
      self.jammed = true
    end
  end
end

function Timer:reset()
  self.count = 0
  self.jammed = false
end

function Timer:getJammed()
  return self.jammed
end

return Timer
