local Timer = {}
Timer.__index = Timer

function Timer.new(timeLimit)
  local self = setmetatable({}, Timer)
  
  self.maxTime = timeLimit
  self.count = 0
  self.jammed = false
  self.isPaused = false
  self.valid = nil
  self.previousDt = 0
  self.timeMultiplier = 1
  if type(self.maxTime) == "number" or self.maxTime == nil then self.valid = true else self.valid = false end

  return self
end


-- O multiplicador indica o quanto que o tempo do contador vai ser
-- multiplicado sempre que incrementado. Por padrão, o valor é 1,
-- o que implica na contagem em segundos padrão.
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



-- O timer atualiza se ele estiver num intervalo válido (contador < tempoMáximo),
-- se ele não estiver travado (contador == tempoMáximo) ou se ele não estiver pausado.
-- Um mero set(0) reinicia o timer a todo vapor.
function Timer:update(dt)
  if not self.isPaused and not self.jammed and self.valid then
    if dt ~= nil then
      self.count = self.count + (dt * self.timeMultiplier)
      self.previousDt = dt
    else
      self.count = self.count + (self.previousDt * self.timeMultiplier)
    end
    if self.maxTime ~= nil then
      if self.count >= self.maxTime then
        self.jammed = true
        self.count = self.maxTime
      elseif self.count < 0 then
        self.count = 0;
      end
    end
  end
end



function Timer:reset()
  self.count = 0
  if self.maxTime ~= 0 then
    self.jammed = false
  end
end



function Timer:isJammed()
  return self.jammed
end



return Timer
