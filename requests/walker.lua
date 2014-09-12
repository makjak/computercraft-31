local state = dofile("/apis/state")
local turtle = dofile("/apis/turtle")
local pmemory = dofile("/apis/pmemory")

pmemory.add("checkpoint")

local function task()
  while true do
    if state.curr == 1 then
      for i=1,16 do
        if turtle.getItemCount(i) > 0 then
          turtle.select(i)
          break
        elseif i == 16 then
          print "Waiting for more items!"
          os.pullEvent("turtle_inventory")
        end
      end

      turtle.place("down")
      turtle.move("forward")
    end

    if state.curr == 2 then
      turtle.turn("back")
      state.set(3)
    end

    if state.curr == 3 then
      turtle.dig("down")
      turtle.move("forward")

      local pos = turtle.position()
      if pos.x == pos.y then return end
    end
  end
end

local function menu()
  term.clear()
  term.setCursorPos(1,1)
  print "Press Q to quit"
  print "Press R to return (please get behind me!)"

  local e, k = os.pullEvent("key")
  
  os.pullEvent("char")
  term.clear()
  term.setCursorPos(1,1)

  if k == keys.q then return 
  elseif k == keys.r then 
    state.set(2)
  end
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
