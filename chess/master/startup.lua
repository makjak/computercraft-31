local util = dofile("/apis/util")
local state = dofile("/apis/state")
local turtle = dofile("/apis/turtle")
local pmemory = dofile("/apis/pmemory")

local function update_check()
end

local function process_move_request()

local function task()
  while true do
    if state.curr == -1 then return
    
    elseif state.curr == 1 then
      -- waiting for a chess game to start
      -- initialize board information
      board = pmemory.read("default_board","table")
      pmemory.write("board",board,"table")      -- default board
      pmemory.write("turn","white","string")    -- white's move
      pmemory.write("epassent","none","string") -- no current epassents
                                                -- no rooks/kings have moved
      pmemory.write("castling", {white = {false,false,false}, black = {false,false,false}}, "table")  
      pmemory.write("promotion", 0, "number")

      repeat
        local id, mes = rednet.receive()
      until mes == "START CHESS - PING" and board[id] ~= nil
      state.set(2)

    elseif state.curr > 1 and state.curr < 34 then
      -- we have received a chess request
      repeat
        rednet.broadcast("START CHESS - PONG")
        -- pieces should be moving into position
        -- they will send information about themselves
        local id, mes = rednet.receive()
        if board[id] ~= nil and mes == "PING" then
          state.set( state.curr + 1 )
        end
      until state.curr == 34
      -- all pieces are accounted for and ready to play chess

    elseif state.curr == 34 then
      -- Chess Move Parsing
      board = pmemory.read("board","table")
      turn = pmemory.read("turn","string")
      epassent = pmemory.read("epassent","table")
      castling = pmemory.read("castling","table")
      promotion = pmemory.read("promotion","number")
      
      repeat -- wait for a move from one of our pieces
        id, mes = rednet.receive()
      until board[id] ~= nil

      -- grab information about the piece
      local color = board[id].color
      local class = board[id].class
      local x, y, z = board[id].x, board[id].y, board[id].z

      -- Process Non-Game Move Messages
      if mes == "RESIGN" and class == "KING" then
        rednet.broadcast("GAME END")
        state.set(-1)

      elseif class == "PAWN" and (x == 0 or x == 21) then
        if class_exists[mes] then
          board[id].class == mes
          pmemory.write("board", board, "table")
          rednet.send("ACCEPT:",id)
          update_check() -- notify kings if they are in check
        else
          rednet.send("REJECT: Can not promote to " .. mes, id )
        end

      elseif turn ~= color then
        rednet.send("REJECT: It is not your turn", id )
      
      elseif promotion == 1 then
        rednet.send("REJECT: Waiting on pawn promotion", id )

      -- Process Game Move Messages
      else
        process_move_request(mes,id) -- the message is a movement request
        update_check()
      end

    else
      print "Error! Aborting Program"
      return
    end -- state select if statement
  end
end

local function menu()
  while true do
    term.clear()
    term.setCursorPos(1,1)
    print "Welcome to the Chess Master Prgm"
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
if state.curr == -1 then
  state.finalize()
  state.set(0)
  os.reboot()
end
