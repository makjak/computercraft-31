--[[
--  Program:  Nexus Portal v3.14.15
--  Author:   Arctivlargl
--  License:  Creative Commons Attribution-ShareAlike 3.0 Unported License.
--            http://creativecommons.org/licenses/by-sa/3.0/
--]]

local util = dofile("/apis/util")
local turtle = dofile("/apis/turtle")
if not util.getPeripheralSide("modem") then turtle.equipLeft() end
if not util.getPeripheralSide("modem") then turtle.equipLeft() end
rednet.open(util.getPeripheralSide("modem"))
rs.setOutput("bottom",true) -- disable the router

local function openPortal()
  -- take the book from the enderchest and put
  -- it into the portal book holder
  turtle.selectEmptySlot()
  turtle.suckDown()
  turtle.dropUp()
end

local function closePortal()
  turtle.selectEmptySlot()
  turtle.suckUp()
  turtle.dropDown()
end

local function network()
  while true do
    local e, sid, msg, dis = os.pullEvent("rednet_message")
    if msg == "OPEN PORTAL" then
      openPortal()
      rednet.send( sid, "PING" )
    elseif msg == "CLOSE PORTAL" then
      closePortal()
      rednet.send( sid, "PING" )
    end
  end
end

local function menu()
  term.clear()
  term.setCursorPos(1,1)
  print "Welcome to the Nexus Router"
  print "---------------------------"
  print " Press Q to quit"

  while true do
    e, k = os.pullEvent("key")
    os.pullEvent("char")
    if k == keys.q then return end
  end
end

parallel.waitForAny( menu, network )
