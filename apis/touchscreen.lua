
-- [[ The following functions are slightly modified versions of Direwolf's touchscreen functions
-- they have been implemented into a much more general purpose touchscreen API and will
-- be further developed if need be ]] --

local self = {}
self.on = colors.lime
self.off = colors.red
self.background = colors.black
self.refresh = false

-- add a button to the layout variable
function self.addButton(button, xmin, xmax, ymin, ymax, name, func, args)
  button[name] = { active=false, xmin=math.floor(xmin+0.5), ymin=math.floor(ymin+0.5), xmax=math.floor(xmax), ymax=math.floor(ymax), func=func, args=args }
end

-- fills the text box        
function self.fill(text, color, bData, monitor)
  monitor.setBackgroundColor(color)
  local yspot = math.floor((bData.ymin + bData.ymax)/2)
  local xspot = math.floor((bData.xmax - bData.xmin - string.len(text))/2)+1
  for j = bData.ymin, bData.ymax do
    monitor.setCursorPos(bData.xmin, j)
    if j == yspot then
      for k = 0, bData.xmax - bData.xmin - string.len(text)+1 do
        if k == xspot then monitor.write(text)
        else monitor.write(" ")
        end
      end
    else
      for i = bData.xmin, bData.xmax do
        monitor.write(" ")
      end
    end
  end
  monitor.setBackgroundColor(self.background)
end

-- allows you to have buttons revert to off when another screen event occurs
function self.update(page, monitor)
  local currColor
  for name,data in pairs(page) do
    local on = data.active
    if on == true then currColor = self.on else currColor = self.off end
    self.fill(name, currColor, data, monitor)
    if self.refresh then data.active = false end
  end
end

-- scans the x,y of the provided layout for a button press      
function self.check(page, x, y)
  local retv = false
  for name, data in pairs(page) do
    if y>=data.ymin and  y <= data.ymax then
      if x>=data.xmin and x<= data.xmax then
        data.func(data.args)
        data.active = not data.active
        retv = true
      end
    end
  end
  return retv
end

-- prints the heading
function self.heading(text, monitor)
  w, h = monitor.getSize()
  monitor.setCursorPos((w-string.len(text))/2+1, 1)
  monitor.write(text)
end


function self.pagenum(i, n, monitor)
  w, h = monitor.getSize()
  monitor.setCursorPos((w-math.log10(i)-math.log10(n)-1)/2+1,h-1)
  monitor.write(i.."/"..n)
end

return self
