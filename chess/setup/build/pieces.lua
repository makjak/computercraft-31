local turtle = dofile("/apis/turtle")
local util = dofile("/apis/util")
local pmemory = dofile("/apis/pmemory")

turtle.selectEmptySlot()
if not util.getPeripheralSide("modem") then turtle.equipLeft() end
if not util.getPeripheralSide("modem") then turtle.equipLeft() end
rednet.open(util.getPeripheralSide("modem"))

shell.run("label","set","master")
turtle.initialize() -- the corner of the board is 0,0,0

pmemory.changeDir("/pmemory-chess-disk")

-- slot 1 : 32 wireless mining turtles
-- slot 2 : 1 disk
-- slot 3 : floppy disk
-- slot 4 : buckets
-- slot 5 : buckets
-- slot 6 : bone meal
-- slot 7 : ink sacs
local MINING_TURTLE = 1
local DISK_DRIVE    = 2
local FLOPPY_DISK   = 3
local BUCKET        = 4
local WHITE_DYE     = 6
local BLACK_DYE     = 7

local random_number = 0
local board = {}

local function write_to_drive(class, color)
  if color == "White" then
    turtle.select(WHITE_DYE)
  elseif color == "Black" then
    turtle.select(BLACK_DYE)
  end
  turtle.place("down")

  local home = {}
  home = turtle.position()
  home.z = home.z - 1
  home.f = turtle.facing()

  data =
  {
    color = color,
    class = class,
    home  = home,
    master = os.getComputerID()
  }

  pmemory.write("data", data, "table")
  random_number = math.random(1,1024)
  pmemory.write("rand", random_number, "number")
  fs.delete("/disk/pmemory")
  fs.copy(pmemory.pPath, "/disk/pmemory")
end

local function deployTurtle(i, row, color)
  turtle.select(MINING_TURTLE)
  turtle.place("down")
  turtle.select(BUCKET + row)
  turtle.drop("down")

  turtle.select(DISK_DRIVE)
  turtle.place("forward")
  turtle.select(FLOPPY_DISK)
  turtle.drop("forward")

  if row == 0 then
    class = "Pawn"
  elseif row == 1 then
    if i == 1 or i == 8 then
      class = "Rook"
    elseif i == 2 or i == 7 then
      class = "Knight"
    elseif i == 3 or i == 5 then
      class = "Bishop"
    elseif i == 4 then
      class = "Queen"
    elseif i == 5 then
      class = "King"
    end
  end
  write_to_drive(class, color)
  
  turtle.suck()
  turtle.select(DISK_DRIVE)
  turtle.dig()
  turtle.move("back")

  turtle.place("forward")
  turtle.select(FLOPPY_DISK)
  turtle.drop("forward")

  turtle.move("down")
  peripheral.call("front","turnOn")
  turtle.move("up")

--[[
  repeat
    id, mes = os.pullEvent("rednet_message")
  until tonumber(mes) = random_number
  board[id] = { class = class, color = color, start = class }
  if class == "KING" then
    board[color] = id
  end
]]--

  turtle.suck()
  turtle.select(DISK_DRIVE)
  turtle.dig()
end

local function init_disk_drive()
  turtle.select(DISK_DRIVE)
  turtle.place()
  turtle.select(FLOPPY_DISK)
  turtle.place()

  fs.copy("/disk-startup", "/disk/startup")
  fs.copy("/piece-startup", "/disk/piece-startup")
  fs.copy("/github", "/disk/github")
  fs.copy("/pasteget", "/disk/pasteget")
  fs.copy("/apis", "/disk/apis")

  turtle.suck()
  turtle.select(DISK_DRIVE)
  turtle.dig()
end

-- initialize the disk drive
init_disk_drive()
--[[
-- move over white turtle deploy
turtle.to({"x:" .. -1,"y:" .. 1, "z:" .. 0, "f:" .. 3})
for i=1,8,1 do
  deployTurtle(i,0,"White")
  deployTurtle(i,1,"White")
  turtle.to({"x:" .. -1})
  turtle.move("right")
end

-- move over black turtle deploy
turtle.to({"x:" .. -1,"y:" .. 15,"z:" .. 0,"f:" .. 3})
for i=8,1,-1 do
  deployTurtle(i,0,"Black")
  turtle.move("back")
  deployTurtle(i,1,"Black")
  turtle.move("forward")
  turtle.move("right")
end

-- move home
turtle.to("x:" .. 0,"y:" .. 0,"z:" .. 0,"f:" .. 0)

pmemory.changeDir("/pmemory")
pmemory.add("board")
pmemory.write("board", board, "table")
]]--
