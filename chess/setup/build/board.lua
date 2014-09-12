local state = dofile("/apis/state")
local turtle = dofile("/apis/turtle")
local pmemory = dofile("/apis/pmemory")

-- slot 15 : white block enderchest
-- slot 16 : black block enderchest

local function task()
  while true do
    if state.curr == 1 then
      -- check the fuel level
      while turtle.getFuelLevel() < 64*9 do
        print("Attempting to use fuel")
        turtle.selectFuel()
        turtle.refuel()
        if turtle.getFuelLevel() < 64*9 then
          print("Waiting on more fuel...")
          os.pullEvent("turtle_inventory")
        end
      end
      state.set(2)
    end

    if state.curr == 2 then
      print "THIS TURTLE IS NOT PERSISTANT DO NOT UNLOAD"
      
      local color = 1
      local direction = "forward"

      for i=1,24 do
        for j=1,24 do
          turtle.select(color+1)
          if turtle.getItemCount(color+1) == 0 then
            turtle.enderFill(16-color,"top")
          end
          if j > 1 then turtle.move(direction) end
          turtle.place("down")
          if (j%3) == 0 then color = 1-color end
        end

        if (i%3) > 0 then color = 1-color end
        if i < 24 then turtle.move("right") end
        direction = turtle.switch(direction)
      end

      -- Close the program successfully
      state.set(-1)
    end

    if state.curr == -1 then return end
  end
end

local function menu()
  while true do
    term.clear()
    term.setCursorPos(1,1)
    print "Constructing Chess Board"
    print "--------------------------------"
    print " Press Q to save and quit"
    print " Press E to quit without saving"

    local e, k = os.pullEvent("key")

    os.pullEvent("char")
    term.clear()
    term.setCursorPos(1,1)

    if k == keys.q then 
      return
    elseif k == keys.e then 
      state.set(-1)
      return
    end
  end
end

state.initialize()
if state.curr == 0 then
  turtle.initialize()
  state.set(1)
end
parallel.waitForAny( menu, task )
if state.curr == -1 then
  term.clear()
  term.setCursorPos(1,1)
  state.finalize()
end
