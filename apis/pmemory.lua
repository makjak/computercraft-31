--[[
--  API:       Persistent Memory
--  Author:    Arctivlargl
--  License:   Creative Commons Attribution-ShareAlike 3.0 Unported License.
--             http://creativecommons.org/licenses/by-sa/3.0/
]]--

local pmemory = {}
pmemory.pPath = "/pmemory"

function pmemory.changeDir(path)
  pmemory.pPath = path
  if not fs.exists(pmemory.pPath) then fs.makeDir(pmemory.pPath) end
end
pmemory.changeDir(pmemory.pPath)


function pmemory.add(pVar)
  if fs.exists(pmemory.pPath.."/"..pVar) then return false
  else pFile = io.open(pmemory.pPath.."/"..pVar,"w") return true
  end
end

function pmemory.remove(pVar)
  fs.delete(pmemory.pPath.."/"..pVar)
end

function pmemory.delete(pVar)
  local file = pmemory.pPath.."/"..pVar
  if not fs.exists(pmemory.pPath.."/"..pVar) then return false
  else shell.run("rm",file)
  end
end

function pmemory.write(pVar, x, dType)
  pmemory.add(pVar) -- create the file if it doesn't exist
  pFile = io.open(pmemory.pPath.."/"..pVar, "r")
  if pFile then
    pFile:close()
    pFile = io.open(pmemory.pPath.."/"..pVar,"w")

    local val
    if dType == "table" then 
      assert(type(x)=="table","write expected a table")
      val = textutils.serialize(x)
    elseif dType == "number" or dType == "int" then
      assert(type(x)=="number","write expected a number")
      val = tostring(x)
    elseif dType == "string" then
      assert(type(x)=="string","write expected a string")
      val = x
    elseif dType == nil then
      if type(x) == "string" then val = x
      else val = textutils.serialize(x)
      end
    else print("Unknown data type for pmemory API")
    end

    pFile:write(val)
    pFile:close()
  end
end

function pmemory.read(pVar, dType)
  pFile = io.open(pmemory.pPath.."/"..pVar, "r")
  if pFile then
    content = pFile:read()
    pFile:close()

    if dType == "number" or dType == "int" then
      return tonumber(content)
    elseif dType == "string" then
      return content
    elseif dType == "table" then
      return textutils.unserialize(content)
    else
      print("Unknown data type for pmemory API -- returning as string")
      return content
    end
  end
end

return pmemory
