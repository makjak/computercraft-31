local files = {
  startup = "piece-startup",
  apis = "apis",
  pmemory = "pmemory",
  github = "github",
  pasteget = "pasteget",
}

for file, disk_file in pairs(files) do
  fs.delete("/"..file)
  fs.copy("/disk/"..disk_file, "/"..file)
end

local pmemory = dofile("/apis/pmemory")
data = pmemory.read("data", "table")
color = data.color
class = data.class
shell.run("label","set", color .. " " .. class)

local util = dofile("/apis/util")
local turtle = dofile("/apis/turtle")
turtle.selectEmptySlot()
if not util.getPeripheralSide("modem") then turtle.equipLeft() end
if not util.getPeripheralSide("modem") then turtle.equipLeft() end

random_number = pmemory.read("rand","number")
rednet.send( random_number, data.master )

os.reboot()
