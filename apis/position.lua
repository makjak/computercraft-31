local self = {}
local pmemory = dofile("/apis/pmemory")

if pmemory.add("position") then pmemory.write("position",{x=0,y=0,z=0,xDir=0,yDir=1},"table") end
position = pmemory.read("position","table")

function self.initialize()
  pmemory.add("position")
  pmemory.write("position",{x=0,y=0,z=0,xDir=0,yDir=1},"table")
  position = pmemory.read("position","table")
end

function self.position()
  return position.x, position.y, position.z
end
local x, y, z = self.position()

function self.directions()
  return position.xDir, position.yDir
end
local xDir, yDir = self.directions()

function self.facing()
  if yDir ~= 0 then return 1-yDir
  else return 2+xDir
  end
end

function self.update(s)
  if s == "forward" then
    x = x + xDir
    y = y + yDir
  elseif s == "back" then
    x = x - xDir
    y = y - yDir
  elseif s == "down" then
    z = z - 1
  elseif s == "up" then
    z = z + 1
  elseif s == "right" then
    xDir, yDir = -yDir, xDir
  elseif s == "left" then
    xDir, yDir = yDir, -xDir
  end 
  pmemory.write("position",{x=x,y=y,z=z,xDir=xDir,yDir=yDir},"table")
  position = pmemory.read("position","table")
end

function self.set(x0,y0,z0,xdir0,ydir0)
  if x0 then x = x0 end
  if y0 then y = y0 end
  if z0 then z = z0 end
  if xdir0 then xDir = xdir0 end
  if ydir0 then yDir = ydir0 end
  pmemory.write("position",{x=x,y=y,z=z,xDir=xDir,yDir=yDir},"table")
  position = pmemory.read("position","table")
end

return self
