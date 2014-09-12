local state = dofile("/apis/state")
local turtle = dofile("/apis/turtle")
local pmemory = dofile("/apis/pmemory")

local item_mine = "minecraft:iron_ore"
pmemory.add("checkpoint")

local tried_backOne = false

local function require_refuel(n)
  local pos = turtle.position()
  local dist = math.abs(pos.x) + math.abs(pos.y) + math.abs(pos.z) + 10

  if n == 2 then
    local pos2 = pmemory.read("checkpoint","table")
    dist = dist + math.abs(pos.x-pos2.x) + math.abs(pos.y-pos2.y) + math.abs(pos.z-pos2.z)
  end

  return turtle.getFuelLevel() < dist
end

local function task()
  while true do
    if state.curr == 1 then
      -- fly up to the sphere
      repeat sleep(0.5) until require_refuel(1) or not turtle.up()
      _, item = turtle.inspectUp()

      if require_refuel(1) then
        state.set(4)
      elseif item.name ~= item_mine then
        print "THIS IS NOT IRON! YOU LIED TO ME"
        state.set(3) -- return home
      else
        turtle.move("up",true) -- move up into the iron
        state.set(2) -- start mining
      end
    end

    if state.curr == 2 then
      if require_refuel(1) then
        state.set(4)
      end

      -- mining time
      local directions = {[1]="right", [2]="front", [3]="left", [4]="back", [5]="failure"}
      for _, dir in ipairs(directions) do
        if dir == "failure" then
          _, item = turtle.inspect("up")
          if item.name ~= item_mine then
            state.set(3)
            break
          elseif not tried_backOne then
            turtle.move("back",true)
            tried_backOne = true
            break
          else
            repeat
              turtle.move("forward",true)
              _, item = turtle.inspect("up")
            until item.name ~= item_mine
            turtle.move("back")
            turtle.move("up",true)
            break
          end
        else
          _, item = turtle.inspect(dir)
          if item.name == item_mine then
            tried_backOne = false
            turtle.turn(dir)
            turtle.move("forward",true)
            break
          end
        end
      end
    end

    if state.curr == 3 then
      turtle.to({"x:" .. 0, "y:" .. 0, "z:" .. 0, "f:" .. 0}, true)
      print("DONE")
      return
    end

    if state.curr == 4 then
      checkpoint = turtle.position
      checkpoint.f = turtle.facing()
      pmemory.write("checkpoint", checkpoint, "table")
      state.set(5)
    end

    if state.curr == 5 then
      turtle.to({"x:" .. 0, "y:" .. 0, "z:" .. 0, "f:" .. 0}, true)
      print("Waiting on fuel")
      os.pullEvent("turtle_inventory")
      turtle.selectFuel()
      turtle.refuel()
      if not require_refuel(2) then
        state.set(6)
      end
    end

    if state.curr == 6 then
      local pos = pmemory.read("checkpoint", "table")
      turtle.to({"z:" .. pos.z, "y:" .. pos.y, "x:" .. pos.x}, true)
      state.set(2)
    end
  end
end

local function menu()
  term.clear()
  term.setCursorPos(1,1)
  print "Press Q to quit"

  local e, k = os.pullEvent("key")
  
  os.pullEvent("char")
  term.clear()
  term.setCursorPos(1,1)

  if k == keys.q then return end
end

term.clear()
term.setCursorPos(1,1)
print "Press any key to start"
os.pullEvent("key")

state.initialize()
if state.curr == 0 then
  turtle.initialize()
  state.set(1)
end
parallel.waitForAny( menu, task )
state.finalize()
pmemory.delete("checkpoint")
