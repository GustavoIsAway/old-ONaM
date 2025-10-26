local utils = {}



function utils.boolToNum(b)
  return (b and 1) or 0
end



function utils.arithToBool(b)
  return (b and true) or false
end



function utils.loadImage(imageName)
  return love.graphics.newImage("assets/imgs/" .. imageName)
end



return utils
