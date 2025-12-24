local utils = {}


utils.colors = {
  -- Básicas
  CL_BLACK        = {0, 0, 0},
  CL_WHITE        = {1, 1, 1},
  CL_GRAY         = {0.5, 0.5, 0.5},

  -- Vermelhos
  CL_RED          = {1, 0, 0},
  CL_STRONG_RED   = {0.85, 0.1, 0.1},
  CL_SOFT_RED     = {1, 0.4, 0.4},
  CL_DARK_RED     = {0.5, 0, 0},

  -- Verdes
  CL_GREEN        = {0, 1, 0},
  CL_STRONG_GREEN = {0.1, 0.85, 0.1},
  CL_SOFT_GREEN   = {0.4, 1, 0.4},
  CL_DARK_GREEN   = {0, 0.5, 0},

  -- Azuis
  CL_BLUE         = {0, 0, 1},
  CL_STRONG_BLUE  = {0.1, 0.1, 0.85},
  CL_SOFT_BLUE    = {0.4, 0.4, 1},
  CL_DARK_BLUE    = {0, 0, 0.5},

  -- Amarelos
  CL_YELLOW       = {1, 1, 0},
  CL_SOFT_YELLOW  = {1, 1, 0.5},
  CL_DARK_YELLOW  = {0.5, 0.5, 0},

  -- Cianos
  CL_CYAN         = {0, 1, 1},
  CL_SOFT_CYAN    = {0.5, 1, 1},
  CL_DARK_CYAN    = {0, 0.5, 0.5},

  -- Magentas
  CL_MAGENTA      = {1, 0, 1},
  CL_SOFT_MAGENTA = {1, 0.5, 1},
  CL_DARK_MAGENTA = {0.5, 0, 0.5},

  -- Laranjas
  CL_ORANGE       = {1, 0.5, 0},
  CL_SOFT_ORANGE  = {1, 0.7, 0.4},
  CL_DARK_ORANGE  = {0.6, 0.3, 0},

  -- Roxos
  CL_PURPLE       = {0.5, 0, 0.5},
  CL_SOFT_PURPLE  = {0.7, 0.4, 0.7},
  CL_DARK_PURPLE  = {0.3, 0, 0.3},

  -- Marrons
  CL_BROWN        = {0.6, 0.3, 0.1},
  CL_SOFT_BROWN   = {0.75, 0.5, 0.3},
  CL_DARK_BROWN   = {0.4, 0.2, 0.05}
}




function utils.boolToNum(b)
  return (b and 1) or 0
end



function utils.arithToBool(b)
  return (b and true) or false
end



function utils.loadImage(imagePath)
  return love.graphics.newImage("assets/imgs/" .. imagePath)
end



--[[
Modo pode ser "static" (para sons carregados inteiramente na memória)
ou "stream", que são carregados à medida que tocam (ideal para músicas)
]]
function utils.loadSound(soundPath, mode)
  return love.audio.newSource("assets/sfx/" .. soundPath, mode)
end



return utils
