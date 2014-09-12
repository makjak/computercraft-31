--[[
--  Program:  Nexus Portal v3.14.15
--  Author:   Arctivlargl
--  License:  Creative Commons Attribution-ShareAlike 3.0 Unported License.
--            http://creativecommons.org/licenses/by-sa/3.0/
--]]

local config = dofile("config")

local pmemory = dofile("/apis/pmemory")
if pmemory.add("portals") then pmemory.write("portals",{},"table") end
if pmemory.add("indices") then pmemory.write("indices",{free={},curr=1},"table") end
if pmemory.add("nturtle") then pmemory.write("nturtle",{},"table") end 
if pmemory.add("open") then pmemory.write("open",-1,"number") end 
local utility = dofile("/apis/util")
local touchscreen = dofile("/apis/touchscreen")
local monitor = utility.getPeripheral("monitor")
rednet.open(utility.getPeripheralSide("modem"))

local function nTurtle(n)
  nturtle = pmemory.read("nturtle","table")
  local index = math.floor((n-1)/(config.nchests*config.chest_size)) + 1
  assert( #nturtle + 1 > index )
  -- if you hit this assert then you need to add more turtles in!
  -- or set the config.nchests / config.chest_size higher and
  -- redistribute the books!
  return nturtle[index]
end

local function getIndex()
  local indices = pmemory.read("indices","table")
  if #indices.free > 0 then return indices.free[1]
  else return indices.curr
  end
end

---- Monitor Functions ----
local pages = {{}}
local pagenum = 1

local function nextpage()
  pagenum = (pagenum % #pages) + 1
end
local function prevpage()
  pagenum = (pagenum - 2) % #pages + 1
end

local function empty()
  local index = pmemory.read("open","number")
  if index == -1 then return end

  repeat
    rednet.send(config.router, "CLOSE PORTAL")
    id, m, d = rednet.receive(0.5)
  until id == config.router and m == "PING"

  repeat
    rednet.send(nTurtle(index), "CLOSE PORTAL "..index)
    id, m, d = rednet.receive(0.5)
  until id == nTurtle(index) and m == "PING"
  pmemory.write("open",-1,"number")
end

local function portal(index)
  local current = pmemory.read("open","number")
  if index == current then return end
  
  empty()
  repeat
    rednet.send(nTurtle(index),"OPEN PORTAL "..index)
    id, m, d = rednet.receive(0.5)
  until id == nTurtle(index) and m == "PING"

  repeat
    rednet.send(config.router, "OPEN PORTAL")
    id, m, d = rednet.receive(0.5)
  until id == config.router and m == "PING"
  
  pmemory.write("open",index,"number")
end

local function refresh_monitor()
  monitor.clear()
  touchscreen.update(pages[pagenum], monitor)
  touchscreen.heading(config.header, monitor)
  touchscreen.pagenum(pagenum, #pages, monitor)
end

local function update_monitor(portals)
  monitor.setTextScale(config.textsize)
  monitor.setTextColor(config.textcolor)
  monitor.setBackgroundColor(config.backcolor)

  pages = {} -- clear our page entries
  if #portals > 0 then
    for i=1,math.ceil(#portals/(config.rows*config.cols)) do
      table.insert(pages,{})
    end
  else table.insert(pages,{})
  end

  local w, h = monitor.getSize()
  local xlen = math.floor((w - (config.cols+1)*config.xspacing) / config.cols)
  local ylen = math.floor((h - config.rows*config.yspacing - config.botspacing - config.topspacing) / (config.rows+1))

  for p, page in ipairs(pages) do
    local y = config.topspacing
    for i=0,config.rows-1 do
      local x = config.xspacing
      for j=0,config.cols-1 do
        local index = config.rows*config.cols*(p-1) + config.rows*j + i + 1
        if index > #portals then break end
        touchscreen.addButton(page,x,x+xlen,y,y+ylen,portals[index].name, portal, portals[index].index)
        x = x + xlen + config.xspacing
      end
      y = y + ylen + config.yspacing
    end

    -- get appropriate spacing for the bottom buttons
    -- insert the final three buttons at the bottom of every page
    y = h - ylen - config.botspacing
    prevx = config.xspacing
    nextx = w - config.xspacing
    if #pages > 1 then
      touchscreen.addButton(page, prevx, prevx+20, y, y+ylen, "Prev Page", prevpage)
      touchscreen.addButton(page, nextx-20, nextx, y, y+ylen, "Next Page", nextpage)
    end
    touchscreen.addButton(page, prevx+20+config.xspacing, nextx-20-config.xspacing, y, y+ylen, "Destroy Portal", empty)
  end

  refresh_monitor()
end

local function network()
  local portalnumber = pmemory.read("open","number")
  while true do
    local e, p, x, y = os.pullEvent("monitor_touch")
    if touchscreen.check(pages[pagenum], x, y) then
      refresh_monitor()
    end
  end
end

local function menu()
  local portals = pmemory.read("portals","table")
  local indices = pmemory.read("indices","table")
  local nturtle = pmemory.read("nturtle","table")
  update_monitor(portals)
  refresh_monitor()

  while true do
    term.clear()
    term.setCursorPos(1,1)
    print "Welcome to the Nexus Portal Server"
    print "----------------------------------"
    print " Press Q to quit"
    print " Press A to add a portal"
    print " Press R to remove a portal"
    print " Press F to find an index"
    print " Press T to add a new turtle"
    print " Press H for help instructions"

    e, k = os.pullEvent("key") -- wait for a key press
    os.pullEvent("char") -- grab the key press from the output
    term.clear()
    term.setCursorPos(1,1)

    if k == keys.q then return
    elseif k == keys.a then
      print "New Location Name : (eg Secret Lair)"
      local input = read()
      local index = getIndex()
      if #indices.free > 0 then table.remove(indices.free,1)
      else indices.curr = indices.curr + 1
      end

      table.insert(portals,{name=input, index=index})
      update_monitor(portals)
      print ("Location "..input.." added to Turtle #"..nTurtle(index))
      print ("Added with index "..index)
    elseif k == keys.r then
      print "Remove which location? : (eg Horrible Void)"
      local input = read()
      for i,portal in ipairs(portals) do
        if input == portal.name then
          local index = portal.index
          table.remove(portals,i)
          update_monitor(portals)
          table.insert(indices.free,index)
          table.sort(indices.free) -- sort the indices to use the lowest value first
          print ("Location "..input.." from Turtle #"..nTurtle(index))
          print ("with index "..index.." has been removed")
        end
      end
    elseif k == keys.f then
      print "Find which location? : (eg Notch's Tavern)"
      local input = read()
      for i, portal in ipairs(portals) do
        if input == portal.name then
          print (portal.name.." has index "..portal.index)
        end
      end
    elseif k == keys.t then
      print "What is the ID of the turtle?"
      local input = read()
      table.insert(nturtle,tonumber(input))
      pmemory.write("nturtle",nturtle,"table")
    elseif k == keys.h then
      print "Please visit http://imgur.com/a/RVdDf for an image walkthrough"
      print "For specific questions on this build consult the README"
      print "For further questions/bugs, message arctivlargl on reddit"
    else
      print "Unrecognized command"
    end

    pmemory.write("portals",portals,"table")
    pmemory.write("indices",indices,"table")
    refresh_monitor()

    
    term.setCursorPos(1,18)
    print "Returning to menu in 10s or on key press"
    local timeout = os.startTimer(10)
    while true do
      local e, t = os.pullEvent()
      if e == "key" then
        os.pullEvent("char")
        break
      elseif e == "timer" and t == timeout then 
        break
      end
    end
  end
end

empty() -- ultimate has an annoying habit of closing portals
touchscreen.refresh = true
touchscreen.on = config.oncolor
touchscreen.off = config.offcolor
touchscreen.background = config.backcolor
parallel.waitForAny( menu, network )
