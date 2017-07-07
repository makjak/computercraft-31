
--********************************************************
--  Module:    Persistent Memory
--  Author:    aljames-arctic
--  License:   Do what you want
--
--  Description:
--      Persistant memory module; saves variables to files
--      in turtles to maintain knowledge across unloading
--      chunks/server restarts.
--********************************************************

--**********************************
-- Module initialization
-- #include required submodules
--**********************************
local pmemory = {}
pmemory.path = "/pmemory"

--**********************************
-- Change the save directory
--**********************************
function pmemory.changeDir(path)
  pmemory.path = path
  if not fs.exists(pmemory.path) then fs.makeDir(pmemory.path) end
end
pmemory.changeDir(pmemory.path)

--**********************************
-- Allocate memory for a variable
--    Returns false if variable exists
--    Returns true if variable is created
--**********************************
function pmemory.add(variable)
  if fs.exists(pmemory.path.."/"..variable) then return false
  else file = io.open(pmemory.path.."/"..variable,"w") return true
  end
end

--**********************************
-- Check if a variable already exists
--**********************************
function pmemory.exists(variable)
  return fs.exists(pmemory.path.."/"..variable)
end

--**********************************
-- Deallocate memory for a variable
--**********************************
function pmemory.remove(variable)
  local file = pmemory.path.."/"..variable
  fs.delete(file)
end

--**********************************
-- Deallocate memory for a variable
--**********************************
function pmemory.delete(variable)
  local file = pmemory.path.."/"..variable
  if not fs.exists(file) then return false
  else shell.run("rm",file)
  end
end

--**********************************
-- Write variable to persistant memory
--**********************************
function pmemory.write(variable, x, data_type)
  pmemory.add(variable) -- create the file if it doesn't exist
  file = io.open(pmemory.path.."/"..variable, "r")
  if file then
    file:close()
    file = io.open(pmemory.path.."/"..variable,"w")

    local val
    if data_type == "table" then 
      assert(type(x)=="table","write expected a table")
      val = textutils.serialize(x)
    elseif data_type == "number" or data_type == "#" then
      assert(type(x)=="number","write expected a number")
      val = tostring(x)
    elseif data_type == "string" then
      assert(type(x)=="string","write expected a string")
      val = x
    elseif data_type == nil then
      if type(x) == "string" then val = x
      else val = textutils.serialize(x)
      end
    else print("Unknown data type for pmemory API")
    end

    file:write(val)
    file:close()
  end
end

--**********************************
-- Read persistant memory variable
--**********************************
function pmemory.read(variable, data_type)
  file = fs.open(pmemory.path.."/"..variable, "r")
  if file then
    content = file:readAll()
    file:close()

    if data_type == "number" or data_type == "#" then
      return tonumber(content)
    elseif data_type == "string" then
      return content
    elseif data_type == "table" then
      return textutils.unserialize(content)
    else
      print("Unknown data type for pmemory API -- returning as string")
      return content
    end
  end
end

--**********************************
-- Initialize a variable if it does
-- not exist yet. Otherwise do nothing
--**********************************
function pmemory.initialize(variable, value, data_type)
  if pmemory.add(variable) then
    pmemory.write(variable, value, data_type)
  end
end

return pmemory
