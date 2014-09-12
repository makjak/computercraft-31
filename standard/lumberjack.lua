local state = dofile("/apis/state")
local turtle = dofile("/apis/turtle")

local function isLog(dir)
  local item = nil
  if dir == "front" then
    s, item = turtle.inspect()
  elseif dir == "up" then
    s, item = turtle.inspectUp()
  end

  return item.name == "minecraft:log"
end

local function task()
  while true do
    if state.curr == 1 then
      -- waiting for tree to grow
      turtle.suck()
      if isLog("front") then
        turtle.dig()
        state.set(2)
      else
        turtle.turnRight()
        sleep(10)
        if turtle.getFuelLevel() < 50 then
          turtle.selectFuel()
          turtle.refuel(10)
        end
      end
    end

    if state.curr == 2 then
      -- tree chopped -- space empty
      turtle.move("forward")
      state.set(3)
    end

    if state.curr == 3 then
      -- chopping upward
      while isLog("up") do
        turtle.digUp()
        turtle.move("up")
      end
      state.set(4)
    end

    if state.curr == 4 then
      -- move back to initial location
      turtle.to({"z:" .. 0, "x:" .. 0, "y:" .. 0, "f:" .. turtle.facing()})
      state.set(5)
    end

    if state.curr == 5 then
      -- plant new tree
      turtle.select(16)
      turtle.place()
      _, item = turtle.inspect()
      if item.name ~= "minecraft:sapling" then
        turtle.drop()
        print("Out of saplings -- Please provide more in slot 16")
        turtle.select(1)
        turtle.dig()
        state.set(6)
      else
        state.set(1)
      end
    end

    if state.curr == 6 then
      -- no saplings left
      repeat
        os.pullEvent("turtle_inventory")
      until turtle.getItemCount(16) > 0
      state.set(5)
    end
  end
end

local function menu()
  while true do
    term.clear()
    term.setCursorPos(1,1)
    print "Welcome to the Turtle Lumberjack"
    print "--------------------------------"
    print " Press Q to quit"

    local e, k = os.pullEvent("key")

    os.pullEvent("char")
    term.clear()
    term.setCursorPos(1,1)

    if k == keys.q then return end
  end
end

state.initialize()
if state.curr == 0 then
  turtle.initialize()
  state.set(1)
end
parallel.waitForAny( menu, task )
state.finalize()
