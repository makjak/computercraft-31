local self = {}
local pmemory = dofile("/apis/pmemory")
local util = dofile("/apis/util")
rednet.open( util.getPeripheralSide("modem") )

if pmemory.add("relays") then pmemory.write("relays",{},"table") end
local trusted = pmemory.read("relays","table")
local NONCE_LIB = {}

-- send a message along the relay points
function self.send( rID, message, WaitUntilPortOpen )
  local sID = os.getComputerID()
  local nonce = math.random(1,1024)
  local relayMessage = sID .. ":" .. rID .. ":" .. nonce .. ":" .. 0 .. ":" .. message
  
  for _, r in pairs(trusted) do
    rednet.send( r, relayMessage, WaitUntilPortOpen )
  end
  return rednet.send( rID, relayMessage, WaitUntilPortOpen )
end

-- send a message until you get a response
-- CAUTION : THIS THROWS OUT MESSAGES!!!
function self.sendUntil( rID, message, timeout )
  repeat 
    self.send( rID, message, true )
  until self.receive( timeout ) == rID
end

-- use the relay points to flood the network
function self.broadcast( message, rID )
  local sID = os.getComputerID()
  local nonce = math.random(1,1500000000) -- make the probability of failure small
  
  local relayMessage = sID .. ":" .. -1 .. ":" .. nonce .. ":" .. -1 .. ":" .. message
  if rID then relayMessage = sID .. ":" .. rID .. ":" .. nonce ..":" .. -1 .. ":" .. message end

  return rednet.broadcast( relayMessage )
end

-- receive function with a timeout
-- does parsing for the other non-local functions
local function raw_receive( timeout )
  local sID, rID, bCast, nonce, message
  if timeout then os.startTimer( timeout ) end

  repeat
    local event, param1, param2, param3 = os.pullEvent()
    if event == "rednet_message" then
      parse = util.strsplit(":", param2)
      if #parse > 4 then
        sID = tonumber( parse[1] )
        rID = tonumber( parse[2] )
        nonce = tonumber( parse[3] )
        bCast = tonumber( parse[4] )
        message = parse[5]
        for i = 6, #parse do message = message .. ":" .. parse[i] end
      end

      for _, v in pairs(NONCE_LIB) do
        if v == nonce then nonce = nil break end
      end -- disregard messages seen before

      if sID == os.getComputerID() then
        nonce = nil
      end

      if nonce then
        table.insert( NONCE_LIB, nonce )
        if #NONCE_LIB > 10 then table.remove( NONCE_LIB, 1 ) end
      end -- add to nonce library and remove oldest nonces

    elseif event == "timer" and param1 == timeout then
      return
    end
  until ( message and sID and rID and bCast and nonce )

  return sID, message, nonce, bCast, rID
end

-- receive function with timeout functionality
function self.receive( timeout )
  local sID, message, nonce, bCast, rID

  repeat
    sID, message, nonce, bCast, rID = raw_receive( timeout )
  until rID == -1 or rID == os.getComputerID()
  -- repeat until it was a broadcast or it was meant for you
  
  return sID, message
end

-- relay function
-- this should be used for relay points (computers whose only job is relaying)
function self.relay()
  local sID, message, nonce, bCast, rID = raw_receive()
  if rID then
    local relayMessage = sID .. ":" .. rID .. ":" .. nonce .. ":" .. bCast .. ":" .. message

    if bCast == -1 then
      rednet.broadcast( relayMessage )
    else
      for _, relay in pairs(trusted) do
        rednet.send( relay, relayMessage, WaitUntilPortOpen )
      end
      rednet.send( rID, relayMessage, WaitUntilPortOpen )
    end
  end

  return sID, message, rID
end

-- relay a message while waiting to receive a message yourself
-- will also relay broadcasts that are being waited for
function self.relayReceive()
  local sID, message, rID

  repeat
    sID, message, rID = self.relay()
  until rID == -1 or rID == os.getComputerID()

  return sID, message
end

return self
