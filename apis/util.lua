local util = {}

-- Function made by Arctivlargl
function util.getPeripheralSide( _peripheral, i )
  for _,v in pairs(rs.getSides()) do
    if i == 1 then i = nil end
    pType = peripheral.getType(v)
    if pType then
      s, e = string.find( pType, _peripheral )
      if s and e then
        if i == nil then return v
        else i = i-1
        end
      end
    end
  end
end

-- Function made by Arctivlargl
function util.getPeripheral( _peripheral, i )
  local side = util.getPeripheralSide( _peripheral, i )
  if side then
    return peripheral.wrap( side )
  end
end

-- Function made by Arctivlargl
function util.printPeripherals()
  for _,v in pairs(rs.getSides()) do
    if v and peripheral.getType(v) then
      print (v .. " : " .. peripheral.getType(v))
    end
  end
end

function util.firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

-- Function made by TheNietsnie
function util.strsplit(delimiter, text)
  local list = {}
  local pos = 1
  while true do
    local first, last = text:find(delimiter, pos)
    if first then -- found?
      table.insert(list, text:sub(pos, first-1))
      pos = last+1
    else
      table.insert(list, text:sub(pos))
      break
    end
  end
  return list
end

-- Function made by TheNietsnie
function util.commavalue(n)
  local left,num,right = string.match(n,'^([^%d]*%d)(%d*)(.-)$')
  return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

-- Function made by TheNietsnie
function util.round (number, precision)
  precision = precision or 0

  local decimal = string.find(tostring(number), ".", nil, true);

  if ( decimal ) then
    local power = 10 ^ precision;

    if ( number >= 0 ) then
      number = math.floor(number * power + 0.5) / power;
    else
      number = math.ceil(number * power - 0.5) / power;      
    end

    -- convert number to string for formatting
    number = tostring(number);          

    -- set cutoff
    local cutoff = number:sub(decimal + 1 + precision);

    -- delete everything after the cutoff
    number = number:gsub(cutoff, "");
  else
    -- number is an integer
    if ( precision > 0 ) then
      number = tostring(number);

      number = number .. ".";

      for i = 1,precision do
        number = number .. "0";
      end
    end
  end    
  return number;
end

-- Function made by TheNietsnie
function util.inBounds(volume, x, y, z)
  return (x <= volume.xEnd and x >= volume.xStart and y <= volume.yEnd and y >= volume.yStart and z <= volume.zEnd and z >= volume.zStart)
end

return util
