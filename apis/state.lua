local self = {}
self.curr = -1

local pmemory = dofile("/apis/pmemory")

function self.initialize()
  if pmemory.add("state") then
    pmemory.write("state",0,"number")
  end

  self.curr = pmemory.read("state","number")
  return true
end

function self.set(x)
  pmemory.add("state")
  pmemory.write("state", x,"number")
  self.curr = x
  return true
end

function self.get()
  if pmemory.add("state") then pmemory.write("state",0,"number") end
  self.curr = pmemory.read("state","number")
  return self.curr
end

function self.finalize()
  pmemory.delete("state")
  self.curr = -1
  return true
end


return self
