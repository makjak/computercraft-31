
--********************************************************
--  Module:   Advanced Turtle Control (Adds functionality)
--  Author:   aljames-arctic
--  License:  Do what you want
--
--  Description:
--    Overwrites/Supplements the basic CC Turtle API with a robust
--    suite of features.
--
--********************************************************

--**********************************
-- Module initialization
-- #include required submodules
--**********************************
local self = {}
local util = dofile("/apis/util")
local position = dofile("/apis/position")

--**********************************
-- Module local variables
--**********************************
local SOUTH, WEST, NORTH, EAST = 0, 1, 2, 3

--**********************************
-- Some Turtle Commands No Changes
-- These are included to allow backwards compatability
--**********************************
function self.equipLeft()
  return turtle.equipLeft()
end

function self.equipRight()
  return turtle.equipRight()
end

function self.getSelectedSlot()
  return turtle.getSelectedSlot()
end

function self.select(i)
  return turtle.select(i) 
end

function self.getItemDetail(slot)
  return turtle.getItemDetail(slot)
end

function self.getFuelLevel()
  return turtle.getFuelLevel()
end

function self.getFuelLimit()
  return turtle.getFuelLimit()
end

function self.inspectUp()
  return turtle.inspectUp()
end

function self.inspectDown()
  return turtle.inspectDown()
end

function self.attackUp()
  return turtle.attackUp()
end

function self.attackDown()
  return turtle.attackDown()
end

function self.digUp()
  return turtle.digUp()
end

function self.digDown()
  return turtle.digDown()
end

function self.detectUp()
  return turtle.detectUp()
end

function self.detectDown()
  return turtle.detectDown()
end

function self.suckUp()
  return turtle.suckUp()
end

function self.suckDown()
  return turtle.suckDown()
end

function self.compareTo(i)
  return turtle.compareTo(i)
end

function self.getItemCount(i)
  return turtle.getItemCount(i)
end

function self.getItemSpace(i)
  return turtle.getItemSpace(i)
end


--**********************************
-- Turtle Commands Slight Tweaks
-- Tweaks are made to maintain backwards compatability
--**********************************
function self.craft(i)
  self.select(16)
  return turtle.craft(i)
end

function self.turnLeft()
  turtle.turnLeft()
  position.update("left")
  return true
end

function self.turnRight()
  turtle.turnRight()
  position.update("right")
  return true
end

--**********************************
-- Return persistant memory position
--**********************************
function self.position()
  return position.position()
end

function self.directions()
  return position.directions()
end

function self.facing()
  return position.facing()
end

--**********************************
-- Selects fuel if able. Otherwise no change
--
-- Returns true if current slot has fuel
-- Otherwise returns true if any slot has fuel
-- Otherwise returns false
--**********************************
function self.selectFuel()
  local current_slot = self.getSelectedSlot()
  if turtle.refuel(0) then return true end

  for i=1,16 do
    self.select(i)
    if turtle.refuel(0) then
      return true
    end
  end
  self.select(current_slot)
  return false
end

--**********************************
--  Returns the opposite direction headed
--    ( useful for turning around )
--**********************************
function self.switch(direction)
  if direction == "forward" or direction == "front" then
    return "backward"
  elseif direction == "backward" or direction == "back" then
    return "forward"
  elseif direction == "right" then
    return "left"
  elseif direction == "left" then
    return "right"
  elseif direction == "up" or direction == "top" then
    return "down"
  elseif direction == "down" or direction == "bottom" then
    return "up"
  end
end

--**********************************
--  Advanced turn functionality
--**********************************
function self.turn( dir )
  if dir == "front" or dir == "top" or dir == "bottom" then
    return true
  elseif dir == "right" then
    return self.turnRight()
  elseif dir == "left" then
    return self.turnLeft()
  elseif dir == "back" then
    return self.turn( "right" ) and self.turn("right")
  elseif type(dir) == "number" then
    local difference = math.floor( dir - self.facing() ) % 4
    if difference == 3 then self.turn("left")
    elseif difference > 0 then 
      for i=1,difference do self.turn("right") end 
    end
    return true
  else
    return false
  end
end

function self.unturn( dir )
  if dir == "front" or dir == "top" or dir == "bottom" then
    return true
  elseif dir == "right" then
    return self.turnLeft()
  elseif dir == "left" then
    return self.turnRight()
  elseif dir == "back" then
    return self.turn("right") and self.turn("right")
  end
end

--**********************************
-- Turtle inspect functionality
--**********************************
function self.inspect(dir)
  local s, r = nil, nil
    
  self.turn(dir)

  if dir == "up" then s, r = turtle.inspectUp()
  elseif dir == "down" then s, r = turtle.inspectDown()
  else s, r = turtle.inspect()
  end

  self.unturn(dir)

  return s, r
end

--**********************************
-- Turtle attack functionality
--**********************************
function self.attack(i)
  if i == "front" then 
    return self.attack()
  elseif i == "top" then 
    return self.attackUp()
  elseif i == "bottom" then 
    return self.attackDown()
  elseif i == "left" or i == "right" or i == "back" then 
    self.turn(i) 
    return self.attack()
  else 
    return turtle.attack()
  end
end

--**********************************
-- Turtle dig functionality
--**********************************
function self.dig(i)
  if i == "front" or i == "forward" then 
    return self.dig()
  elseif i == "top" or i == "up" then 
    return self.digUp()
  elseif i == "bottom" or i == "down" then 
    return self.digDown()
  elseif i == "left" or i == "right" or i == "back" then 
    self.turn(i) 
    return self.dig()
  else 
    return turtle.dig()
  end
end

--**********************************
-- Turtle movement functionality
--**********************************
function self.forward()
  local fuel = self.getFuelLevel()
  turtle.forward()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("forward") end
  return moved
end

function self.back()
  local fuel = self.getFuelLevel()
  turtle.back()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("back") end
  return moved
end

function self.up()
  local fuel = self.getFuelLevel()
  turtle.up()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("up") end
  return moved
end

function self.down()
  local fuel = self.getFuelLevel()
  turtle.down()
  local moved = fuel ~= self.getFuelLevel()
  if moved then position.update("down") end
  return moved
end

--**********************************
--Provide a value for x to allow digging/attacking
--**********************************
local function moveForward(x)
  while not self.forward() do
    if x ~= nil then
      self.attack()
      self.dig()
    end
    sleep(0.5)
  end
  return true
end

local function moveBack(x)
  if x == nil then
    while not self.back() do
      sleep(0.5)
    end
  else
    if not self.back() then
      self.turn("back")
      moveForward(x) -- attack/dig forward
      self.turn("back")
    end
  end
  return true
end

local function moveUp(x)
  while not self.up() do
    if x ~= nil then
      self.attackUp()
      self.digUp()
    end
    sleep(0.5)
  end
  return true
end

local function moveDown(x)
  while not self.down() do 
    if x ~= nil then
      self.attackDown()
      self.digDown()
    end
    sleep(0.5) 
  end
  return true
end

--**********************************
-- Multiple block movement
--
-- Provide a value for x to allow dig/attack
--**********************************
function self.move(direction, x)
  if direction == "forward" then
    moveForward(x)
  elseif direction == "right" or direction == "left" then
    self.turn(direction)
    moveForward(x)
    self.unturn(direction)
  elseif direction == "backward" or direction == "back" then
    moveBack(x)
  elseif direction == "up" then
    moveUp(x)
  elseif direction == "down" then
    moveDown(x)
  else assert(false)
  end
end

function self.place(dir, string)
  local current_slot = self.getSelectedSlot()
  if dir == "top" or dir == "up" then 
    local retv = turtle.placeUp()
    return retv, self.getItemCount(current_slot)
  elseif dir == "bottom" or dir == "down" then 
    local retv = turtle.placeDown()
    return retv, self.getItemCount(current_slot)
  end

  self.turn(dir)
  local retv = turtle.place(string)
  self.unturn(dir)

  return retv, self.getItemCount(current_slot)
end

function self.placeUp()
  local current_slot = self.getSelectedSlot()
  local retv = turtle.placeUp()
  return retv, self.getItemCount(current_slot)
end

function self.placeDown()
  local current_slot = self.getSelectedSlot()
  local retv = turtle.placeDown()
  return retv, self.getItemCount(current_slot)
end

function self.detect(dir)
  local is_obj = false

  self.turn(dir)
  
  if dir == "up" then is_obj = turtle.detectUp()
  elseif dir == "down" then is_obj = turtle.detectDown()
  else is_obj = turtle.detect()
  end

  self.unturn(dir)

  return is_obj
end

function self.compareUp(x)
  local current_slot = self.getSelectedSlot()
  if x == nil then
    return turtle.compareUp()
  end

  for i=1,16 do
    if self.getItemCount(i) > 0 then
      self.select(i)
      if turtle.compareUp() then
        self.select(current_slot)
        return true, i
      end
    end
  end

  return false, 0
end

function self.compareDown(x)
  local current_slot = self.getSelectedSlot()
  if x == nil then
    return turtle.compareDown()
  end

  for i=1,16 do
    if self.getItemCount(i) > 0 then
      self.select(i)
      if turtle.compareDown() then
        self.select(current_slot)
        return true, i
      end
    end
  end

  return false, 0
end

function self.compare(x)
  local current_slot = self.getSelectedSlot()
  if x == nil then
    return turtle.compare()
  end

  for i=1,16 do
    if self.getItemCount(i) > 0 then
      self.select(i)
      if turtle.compare() then
        self.select(current_slot)
        return true, i
      end
    end
  end

  return false, 0
end

function self.dropUp(i)
  if i then return turtle.dropUp(i)
  else return turtle.dropUp()
  end
end

function self.dropDown(i)
  if i then return turtle.dropDown(i)
  else return turtle.dropDown()
  end
end

function self.drop(i,j)
  if i == "front" or i == "forward" then 
    return self.drop(j)
  elseif i == "top" or i == "up" then 
    return self.dropUp(j)
  elseif i == "bottom" or i == "down" then 
    return self.dropDown(j)
  elseif i == "left" or i == "right" or i == "back" or i == "backward" then 
    self.turn(i) 
    return self.drop(j)
  elseif i then 
    return turtle.drop(i)
  else 
    return turtle.drop()
  end
end

function self.suck(i)
  if i == "front" or i == "forward" then 
    return self.suck()
  elseif i == "top" or i == "up" then 
    return self.suckUp()
  elseif i == "bottom" or i == "down" then 
    return self.suckDown()
  elseif i == "left" or i == "right" or i == "back" or i == "backward" then 
    self.turn(i) 
    return self.suck()
  else 
    return turtle.suck()
  end
end

function self.refuel(i)
  if i then return turtle.refuel(i)
  else return turtle.refuel()
  end
end

function self.transferTo(i,n)
  local current_slot = self.getSelectedSlot()
  if not n then 
    n = self.getItemCount( current_slot )
  end
  return turtle.transferTo(i,n)
end

function self.setPosition(x,y,z,xDir,yDir)
  position.set(x,y,z,xDir,yDir)
end

function self.emptySlot()
  for i = 1,16 do
    if self.getItemCount(i) == 0 then
      return i
    end
  end
end

function self.selectEmptySlot()
  slot = self.emptySlot()
  if slot then
    self.select(slot)
    return true
  end
end

function self.swap(i,j)
  local current_slot = self.getSelectedSlot()
  empty = self.emptySlot()
  if slot == nil then return end

  self.select(i)
  self.transferTo(empty)
  self.select(j)
  self.transferTo(i)
  self.select(empty)
  self.transferTo(j)

  self.select(current_slot)
end

function self.enderFill(enderChest, direction, x)
  local current_slot = self.getSelectedSlot()
  if direction == "left" or direction == "right" or direction == "back" then
    self.turn(direction)
    self.enderFill(enderChest, "forward", x)
    self.unturn(direction)
  end

  self.select(enderChest)
  while not self.place(direction) do
    if x then
      self.dig(direction)
      self.attack(direction)
    end
    sleep(0.5)
  end
  self.select(current_slot)
  while not self.suck(direction) do sleep(0.5) end
  self.select(enderChest)
  self.dig(direction)
  self.select(current_slot)
  return true
end

-- function made by TheNietsnie for a beekeeper program
-- updated to integrated use with Arctivlargl API
function self.to(directions,x)
  for i = 1, #directions do
    local coord = util.strsplit(':', directions[i])        
    local coordValue = tonumber(coord[2])
    local pos = self.position()
    local currX, currY, currZ = pos.x, pos.y, pos.z

    if coord[1] == "x" then
      local distanceToMove = currX - coordValue
      if distanceToMove < 0 then self.turn(EAST)
      elseif distanceToMove > 0 then self.turn(WEST) end
      for i=1,math.abs(distanceToMove) do self.move("forward",x) end
    elseif coord[1] == "y" then
      local distanceToMove = currY - coordValue
      if distanceToMove > 0 then self.turn(NORTH)
      elseif distanceToMove < 0 then self.turn(SOUTH) end
      for i=1,math.abs(distanceToMove) do self.move("forward",x) end
    elseif coord[1] == "z" then                    
      local distanceToMove = currZ - coordValue
      if distanceToMove > 0 then
        for i=1,math.abs(distanceToMove) do self.move("down",x) end
      elseif distanceToMove < 0 then
        for i=1,math.abs(distanceToMove) do self.move("up",x) end
      end
    elseif coord[1] == "f" then
      self.turn(coordValue)
    end
    
    if coord[1] == "forward" then
      for i=1,math.abs(coordValue) do self.move("forward",x) end
    elseif coord[1] == "backward" then
      for i=1,math.abs(coordValue) do self.move("backward",x) end
    elseif coord[1] == "up" then
      for i=1,math.abs(coordValue) do self.move("up",x) end
    elseif coord[1] == "down" then
      for i=1,math.abs(coordValue) do self.move("down",x) end
    end
  end

  return true
end

--**********************************
-- Initialize Turtle
--**********************************
function self.initialize()
  position.initialize()
  self.select(1)
end

return self
