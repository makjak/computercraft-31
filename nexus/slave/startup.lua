--[[
--  Portal v3.14.15
--  Author:    Arctivlargl
--  License:   Creative Commons Attribution-ShareAlike 3.0 Unported License.
--             http://creativecommons.org/licenses/by-sa/3.0/
--]]
local config = dofile("config")

local utility = dofile("apis/util")
local turtle = dofile("apis/turtle")
local inventory = utility.getPeripheral("inventory")
if not utility.getPeripheralSide("modem") then turtle.equipLeft() end
if not utility.getPeripheralSide("modem") then turtle.equipLeft() end
rednet.open(utility.getPeripheralSide("modem"))

local function placeAt(n)
  local index = math.fmod(n-1,config.nchests*config.chest_size)+1 -- turtle relative index
  local side = math.floor((index-1)/config.chest_size) -- chest number
  index = math.fmod(index-1,config.chest_size)+1 -- chest relative index

  turtle.to({"f:"..side})
  if inventory and inventory.drop then
    inventory.drop(index,1)
  else
    turtle.drop()
  end
end

local function open_portal(n,sid)
  local index = math.fmod(n-1,config.nchests*config.chest_size)+1 -- turtle relative index
  local side = math.floor((index-1)/config.chest_size) -- chest number
  index = math.fmod(index-1,config.chest_size)+1 -- chest relative index

  turtle.selectEmptySlot()
  turtle.to({"f:"..side})


  if inventory and inventory.suck then
    inventory.suck(index,1)
    turtle.dropDown()
  elseif index > 15 then
    print( "ERROR : Index too high without an inventory mod" )
  else
    for i=0,index do
      turtle.suck()
    end
    
    turtle.select(index)
    turtle.dropDown()

    for i=0,index-1 do
      turtle.select(i)
      turtle.drop()
    end
  end
  
  rednet.send(sid, "PING")
end

local function close_portal(n,sid)
  turtle.selectEmptySlot()
  turtle.suckDown()
  rednet.send(sid, "PING")
  placeAt(n)
end

local function network()
  while true do
    local event,sid,msg,dis = os.pullEvent("rednet_message")

    local s1, e1, s2, e2
    s1, e1 = string.find(msg,"OPEN PORTAL ")
    s2, e2 = string.find(msg,"CLOSE PORTAL ")

    if s1 ~= nil and e1 ~= nil then
      open_portal(tonumber(string.sub(msg, e1+1)),sid)
    elseif s2 ~= nil and e2 ~= nil then
      close_portal(tonumber(string.sub(msg, e2+1)),sid)
    end
  end
end

local function menu()
  while true do
    term.clear()
    term.setCursorPos(1,1)
    print "Welcome to the Nexus Portal Slave"
    print "---------------------------------"
    print " Press Q to quit"
    print " Press A to add a linking book"

    local e, k = os.pullEvent("key")
    os.pullEvent("char")
    term.clear()
    term.setCursorPos(1,1)

    if k == keys.q then return
    elseif k == keys.a then
      print("What index should I put this at?")
      index = read()

      for i=1,16 do
        if turtle.getItemCount(i) > 0 then
          turtle.select(i)
          placeAt(index)
        end
      end

      print("Linking book placed at index "..index)
    end 
  end
end

parallel.waitForAny( menu, network )
