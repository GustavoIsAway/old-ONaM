local CollBox = require("scripts.classes.CollisionBox")
local CollCircle = require("scripts.classes.CollisionCircle")
local utils = require("scripts.utils")


local Button = {}
Button.__index = Button


function Button.new(x, y, shapeInfo, text, collisionType, callback)
  local self = setmetatable({}, Button)

  self.x, self.y = x, y

  self.text = nil
  self.shapeTable = nil
  self.shapeColor = {1, 1, 1, 1}
  self.textColor = {1, 1 ,1}
  self.image = nil
  self.alphaValue = 1

  
  self.callback = callback or function() end
  self.hovered  = false
  self.pressed  = false
  self.vanished = false
  self.collisionType = collisionType
  
  self.dragging = false
  self.dragOffsetX = 0
  self.dragOffsetY = 0
  self.activatePrintPos = true
  
  if type(shapeInfo) == "string" then
    self.image = utils.loadImage(shapeInfo)
    self.width, self.height = self.image:getWidth(), self.image:getHeight()
    if self.collisionType == "circle" then         -- Supõe imagem quadrada
      self.radius = self.width / 2
      self.collision = CollCircle.new(self.x + (self.image:getWidth() / 2), self.y + (self.image:getHeight() / 2), self.radius)
    elseif self.collisionType == "rect" then
      self.collision = CollBox.new(self.x, self.y, self.width, self.height)
    else
      error("class Button: tipo inválido de colisão fornecido")
    end

  elseif type(shapeInfo) == "table" then
    self.shapeTable = shapeInfo
    if #self.shapeTable == 1 then
      self.radius = self.shapeTable[1]
      self.collision = CollCircle.new(self.x, self.y, self.radius)
    elseif #self.shapeTable == 2 then
      self.width = self.shapeTable[1]
      self.height = self.shapeTable[2]
      self.collision = CollBox.new(self.x, self.y, self.width, self.height)
    else
      error("class Button: formato de tabela Shape inválido")
    end

  end
  
  if type(text) == "string" then
    self.text = text
  elseif type(text) == "number" then
    self.text = tostring(text)
  end



  return self
end




function Button:dragWithRightMouse(mouseX, mouseY)
  if self.vanished then return end

  local rightDown = love.mouse.isDown(2)

  -- Começar a arrastar
  if rightDown and not self.dragging then
    if self.collision:checkMouseColl(mouseX, mouseY) then
      self.dragging = true
      self.dragOffsetX = mouseX - self.x
      self.dragOffsetY = mouseY - self.y
    end
  end

  -- Se estiver arrastando, atualizar posição
  if self.dragging then
    if rightDown then
      self.x = mouseX - self.dragOffsetX
      self.y = mouseY - self.dragOffsetY
      self.collision:setPos(self.x, self.y)
      if self.collisionType == "circle" then         -- Supõe imagem quadrada
        if self.image then
          self.collision = CollCircle.new(self.x + (self.image:getWidth() / 2), self.y + (self.image:getHeight() / 2), self.radius)
        else
          self.collision = CollCircle.new(self.x, self.y, self.radius)
        end
      else
        self.collision = CollBox.new(self.x, self.y, self.width, self.height)
      end
    else
      self.dragging = false
    end
  end
end





function Button:update(mouseX, mouseY, mousePressed)            -- Retorna se foi pressionado
  local isHover = self.collision:checkMouseColl(mouseX, mouseY)
  
  if isHover and not self.hovered then
    self.hovered = true
  elseif not isHover and self.hovered then
    self.hovered = false
  end
  
  if isHover and mousePressed and not self.pressed then
    self.pressed = true
    self.callback()
  elseif not mousePressed then
    self.pressed = false
  end

  self:dragWithRightMouse(mouseX, mouseY)
end




function Button:makeVanish()
  if not self.collision then
    error("class Button: colisor inexistente para makeVanish().")
  end
  self.collision:disable()
  self.vanished = true
end




function Button:makeAppear()
  if not self.collision then
    error("class Button: colisor inexistente para makeAppear().")
  end
  self.collision:enable()
  self.vanished = false
end




function Button:didVanish()
  return self.vanished
end



-- Quatro parâmetros simples: (R, G, B, Alpha)
function Button:setColor(colorTable)
  if not self.shapeTable then
    error("class Button: setColor não funciona sem uma shapeTable.")
  elseif type(colorTable) ~= "table" then
    error("class Button: parâmetro passado para setColor não é tabela.")
  elseif #colorTable ~= 3 then
    error("class Button: tamanho de tabela inválido")
  end

  self.shapeColor = colorTable
end




function Button:setAlpha(alphaValue)
  if not type(alphaValue) == "number" then
    error("class Button: setAlpha recebeu tipo não numérico.")
  elseif alphaValue > 1 or alphaValue < 0 then
    error("class Button: setAlpha recebeu valor fora do intervalo 0 a 1")
  end

  self.alphaValue = alphaValue
end




function Button:setPos(x, y)
  self.x = x
  self.y = y
  if self.collisionType == "circle" then
    self.collision:setPos(x + (self.width / 2), y + (self.height / 2))
  elseif self.collisionType == "rect" then
    self.collision:setPos(x, y)
  end
end



function Button:draw()
  if not self:didVanish() then
    if self.activatePrintPos then
      love.graphics.print("x = " .. tostring(self.x) .. ";" .. "y = " .. tostring(self.y) .. ";",
        self.x,
        self.y - 20
      )
    end


    if self.image then
      if self.hovered then
        love.graphics.setColor(0.8, 0.8, 0.8, 1)
      end

      love.graphics.draw(self.image, self.x, self.y)

    elseif self.shapeTable then
      if not self.hovered then
        love.graphics.setColor(self.shapeColor[1], self.shapeColor[2], self.shapeColor[3], self.alphaValue)
      else
        love.graphics.setColor(self.shapeColor[1] - 0.2, self.shapeColor[2] - 0.2, self.shapeColor[3] - 0.2, self.alphaValue)
      end

      if self.collisionType == "rect" then
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
      elseif self.collision == "circle" then
        love.graphics.circle("fill", self.x, self.y, self.radius)
      end
    end
  end


  love.graphics.setColor(1, 1, 1, 1)
end


return Button
