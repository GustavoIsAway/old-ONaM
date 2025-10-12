--IMPORTS

local utils = require("scripts.utils")
local Timer = require("scripts.classes.Timer")
local bit = require("bit")
local CollBox = require("scripts.classes.CollisionBox")
local Tablet = require("scripts.classes.Tablet")
local TabletSystem = require("scripts.classes.TabletSystem")

-- ESTRUTURAS DE DADOS
local enumMov = {
  DIREITA = 1,
  ESQUERDA = -1,
  CIMA = 1,
  BAIXO = -1
}

local dictColors = {
  WHITE = {255, 255, 255},
  BLACK = {0, 0, 0},
  GREEN = {0, 160, 0},
  RED = {160, 0, 0},
  BLUE = {0, 0, 160}
}


-- VARIÁVEIS
local generalTimer = Timer.new(100)
local touchingRight = false
local touchingLeft = false
local mousePos = {}
local hDivision = 6
local toggleDebugInfo = 1

-- ESCALA E POSICIONAMENTO
local baseWidth, baseHeight = 800, 600
local currentScale = 1
local offsetX, offsetY = 0, 0


-- EXEMPLOS
Bck = {}
Bck.image = utils.loadImage("Sala.jpg")
Bck.x = 0
Bck.y = -90
Bck.speed = nil


-- Dimensões da tela e da imagem
local screenW, screenH = baseWidth, baseHeight
local imgW, imgH = Bck.image:getWidth(), Bck.image:getHeight()
local painel = Tablet.new(screenW, screenH)
local mouseCol = false
local sistemaTablet = TabletSystem.new(screenW, screenH)




-- FUNÇÃO DE REDIMENSIONAMENTO
function love.resize(w, h)
  local scaleX = w / baseWidth
  local scaleY = h / baseHeight
  currentScale = math.min(scaleX, scaleY)
  offsetX = (w - baseWidth * currentScale) / 2
  offsetY = (h - baseHeight * currentScale) / 2
end




function love.update(dt)
  local width, height = love.graphics.getDimensions()
  Bck.speed = 600 * dt
  
  -- Ajusta a posição real do mouse pro sistema de coordenadas escalado
  mousePos[1] = (love.mouse.getX() - offsetX) / currentScale
  mousePos[2] = (love.mouse.getY() - offsetY) / currentScale

  if mousePos[1] > screenW - (screenW / hDivision) then
    touchingRight = true
    touchingLeft = false
  elseif mousePos[1] < screenW / hDivision then
    touchingRight = false
    touchingLeft = true
  else
    touchingLeft = false
    touchingRight = false
  end

  if not painel:getTabletState() then
    if touchingRight then
      Bck.x = Bck.x - Bck.speed
    elseif touchingLeft then
      Bck.x = Bck.x + Bck.speed
    end
  end

  -- Limita a posição da imagem para não sair da tela
  if Bck.x > 0 then Bck.x = 0 end                            -- lado direito da imagem
  if Bck.x < screenW - imgW then Bck.x = screenW - imgW end  -- lado esquerdo

  painel:update(dt, mousePos[1], mousePos[2])
  sistemaTablet:update(dt, painel:getTabletState())
  generalTimer:update(dt)
end




function love.keypressed(key)
  if key == "q" then
    toggleDebugInfo = bit.bxor(toggleDebugInfo, 1)
  end
end




function love.draw()
  -- Aplica escala e offset
  love.graphics.push()
  love.graphics.translate(offsetX, offsetY)
  love.graphics.scale(currentScale, currentScale)

  drawGameWorld()

  love.graphics.pop()

  -- Desenha as barras pretas nas bordas
  drawLetterbox()
end




function drawGameWorld()
  -- CENÁRIO
  if (not painel:getTabletState()) then
    love.graphics.draw(Bck.image, Bck.x, Bck.y)
  end
  
  painel:draw()
  sistemaTablet:draw()

  -- INFOS DE DEBUG
  love.graphics.setColor(1, 1, 1, 1)
  if toggleDebugInfo == 1 then
    love.graphics.print("BackgroundPos: " .. math.floor(Bck.x) .. ", " .. math.floor(Bck.y), 0, 0)
    love.graphics.print("MousePos: " .. math.floor(mousePos[1]) .. ", " .. math.floor(mousePos[2]), 0, 12)
    love.graphics.print("FPS: " .. love.timer.getFPS(), 0, 24)
    love.graphics.print("Timer: " .. math.floor(generalTimer:get()), 0, 36)
    love.graphics.print("Dim: " .. love.graphics.getWidth() .. ", " .. love.graphics.getHeight(), 0, 48)
    love.graphics.print("Scale: " .. string.format("%.2f", currentScale), 0, 60)
    love.graphics.print("touchingLeft: " .. tostring(touchingLeft), 0, 72)
    love.graphics.print("touchingRight: " .. tostring(touchingRight), 0, 84)
    love.graphics.print("mouseCol: " .. tostring(mouseCol), 0, 96)
  end
end




-- FUNÇÃO DE LETTERBOX (barras pretas)
function drawLetterbox()
  local windowW, windowH = love.graphics.getDimensions()
  local gameW, gameH = baseWidth * currentScale, baseHeight * currentScale

  love.graphics.setColor(0, 0, 0, 1)

  -- Barras verticais (laterais)
  if gameW < windowW then
    local side = (windowW - gameW) / 2
    love.graphics.rectangle("fill", 0, 0, side, windowH)                     -- esquerda
    love.graphics.rectangle("fill", windowW - side, 0, side, windowH)        -- direita
  end

  -- Barras horizontais (topo/base)
  if gameH < windowH then
    local top = (windowH - gameH) / 2
    love.graphics.rectangle("fill", 0, 0, windowW, top)                      -- topo
    love.graphics.rectangle("fill", 0, windowH - top, windowW, top)          -- base
  end

  love.graphics.setColor(1, 1, 1, 1)
end
