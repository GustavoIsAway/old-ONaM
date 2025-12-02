
local CollCircle = {}
CollCircle.__index = CollCircle



function CollCircle.new(x, y, radius)
    local self = setmetatable({}, CollCircle)
    self.centerX = x
    self.centerY = y
    self.radius = radius
    self.isOn = true
    self.color = {0, 160, 0}

    return self
end



function CollCircle:checkMouseColl(mouseX, mouseY)
    if not self.isOn then
        return false
    end

    local dx = mouseX - self.centerX
    local dy = mouseY - self.centerY
    return (dx*dx + dy*dy) <= (self.radius * self.radius)
end



function CollCircle:enable()
    self.isOn = true
    self.color = {0, 160, 0}
end



function CollCircle:disable()
    self.isOn = false
    self.color = {160, 0, 0}
end



function CollCircle:isEnable()
    return self.isOn
end



function CollCircle:setPos(newX, newY)
    self.centerX, self.centerY = newX, newY
end



function CollCircle:setRadius(newRadius)
    self.radius = newRadius
end



function CollCircle:draw(alpha)
    love.graphics.push("all")
    love.graphics.setColor(
        self.color[1],
        self.color[2],
        self.color[3],
        alpha or 0.5
    )

    love.graphics.circle(
        "fill",
        self.centerX,
        self.centerY,
        self.radius
    )

    love.graphics.pop()
end



return CollCircle
