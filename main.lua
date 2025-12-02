math.randomseed(os.time())
math.random(); math.random(); math.random() -- Saca 3 números do RNG pra "desviciar" um pouco os resultados

local utils         = require("scripts.utils")
local Timer         = require("scripts.classes.Timer")
local TabletSystem  = require("scripts.classes.TabletSystem")
local Tablet        = require("scripts.classes.Tablet")
local Clock         = require("scripts.classes.Clock")
local Sock          = require("scripts.classes.enemies.Sock")
local Bear          = require("scripts.classes.enemies.Bear")
local Snake         = require("scripts.classes.enemies.Snake")
local EyeEnemy      = require("scripts.classes.enemies.EyeEnemy")

-- ESCALA E POSICIONAMENT
local baseWidth, baseHeight = 800, 600
local currentScale = 1
local offsetX, offsetY = 0, 0
local hDivision = 6

-- BACKGROUND
local Bck = {image = utils.loadImage("Sala.jpg"), x = 0, y = -90, speed = 0}

-- TELA
local painel = Tablet.new(baseWidth, baseHeight)
local sistemaTablet = TabletSystem.new(baseWidth, baseHeight)

-- MOUSE
local mousePos = {}

-- CANVAS
local renderCanvas

-- DEBUG
local jeffKill, meiaKill, lennyKill
local bearKillOrStall = {}
local showDebug    = true
local generalTimer = Timer.new(nil)
local mode         = nil
local playerCamera = nil
local clock        = Clock.new(4, 576)

-- INIMIGOS
jeffWarzatski      = EyeEnemy.new(0, 0, 12)
lenny              = Snake.new(0, 0, 12)
meia               = Sock.new(0, 0, 12)
urso               = Bear.new(0, 0, 12)



function love.load()
  love.graphics.setDefaultFilter("nearest","nearest")
  renderCanvas = love.graphics.newCanvas(baseWidth, baseHeight)
end




function love.resize(w, h)
  local scaleX, scaleY = w/baseWidth, h/baseHeight
  currentScale = math.min(scaleX, scaleY)
  offsetX = (w - baseWidth * currentScale)/2
  offsetY = (h - baseHeight * currentScale)/2
end




function love.update(dt)
  generalTimer:update(dt)
  playerCamera, mode = sistemaTablet:getCamera()
  mousePos[1] = (love.mouse.getX() - offsetX)/currentScale
  mousePos[2] = (love.mouse.getY() - offsetY)/currentScale

  -- movimento de background
  if not painel:getTabletState() then
    if mousePos[1] > baseWidth - (baseWidth/hDivision) then
      Bck.x = Bck.x - 600*dt
    elseif mousePos[1] < baseWidth/hDivision then
      Bck.x = Bck.x + 600*dt
    end
    local imgW = Bck.image:getWidth()
    if Bck.x > 0 then Bck.x = 0 end
    if Bck.x < baseWidth-imgW then Bck.x = baseWidth - imgW end
  end

  clock:update(dt)
  painel:update(dt, mousePos[1], mousePos[2])
  sistemaTablet:update(dt, mousePos[1], mousePos[2], painel.isOn)
  jeffKill = jeffWarzatski:update(dt, {playerCamera, mode}, painel.isOn, bearKillOrStall[2])
  lennyKill = lenny:update(dt, {playerCamera, mode}, painel.isOn, sistemaTablet:getLockedDuct(), bearKillOrStall[2])
  meiaKill = meia:update(dt, {playerCamera, mode}, painel.isOn, bearKillOrStall[2])
  bearKillOrStall = urso:update(dt, mousePos, painel.isOn)
end




function love.keypressed(key)
  if key == "q" then
    showDebug = not showDebug
  end
end




function love.draw()
  love.graphics.setCanvas(renderCanvas)
  love.graphics.clear(0, 0, 0, 1)

  -- background
  love.graphics.draw(Bck.image, Bck.x, Bck.y)

  urso:draw()
  sistemaTablet:draw()
  lenny:draw()
  jeffWarzatski:draw()
  meia:draw()
  painel:draw()
  clock:draw()

  love.graphics.setCanvas()
  love.graphics.push()
  love.graphics.translate(offsetX, offsetY)
  love.graphics.scale(currentScale, currentScale)
  love.graphics.draw(renderCanvas, 0, 0)
  love.graphics.pop()

  -- debug info
  if showDebug then
    drawDebug()
  end
end




function drawDebug()
  love.graphics.setColor(1,1,1,1)
  local y = 4
  local function dbg(text)
    love.graphics.print(text, 4, y)
    y = y + 12
  end

  local cameraGets = {}
  cameraGets[1], cameraGets[2] = sistemaTablet:getCamera()

  dbg("FPS: " .. love.timer.getFPS())
  dbg("Timer: " .. string.format("%.2f", generalTimer:get()))
  dbg("Mouse (raw): " .. love.mouse.getX() .. ", " .. love.mouse.getY())
  dbg("Mouse (scaled): " .. math.floor(mousePos[1]) .. ", " .. math.floor(mousePos[2]))
  dbg("Scale: " .. string.format("%.2f", currentScale))
  dbg("Offset: " .. math.floor(offsetX) .. ", " .. math.floor(offsetY))
  dbg("Window: " .. love.graphics.getWidth() .. "x" .. love.graphics.getHeight())
  dbg("Canvas: " .. baseWidth .. "x" .. baseHeight)
  dbg("Background: " .. math.floor(Bck.x) .. ", " .. math.floor(Bck.y))
  dbg("Tablet ativo: " .. tostring(painel.isOn))
  dbg("Q: alterna debug info")
  dbg("Current Camera/Mode: " .. cameraGets[1] .. ", " ..cameraGets[2])
  dbg("Duto trancado: " .. sistemaTablet:getLockedDuct()[1] .. ", " .. sistemaTablet:getLockedDuct()[2])
  dbg("Meia Timer: " .. string.format("%.2f", meia.movementOpportunityTimer:get()))
end
