local self = {}

-- Slave Settings (MUST be the same across all slaves)
self.nchests = 4
self.chest_size = 108

-- Router Settings
self.router = 20

-- Monitor Settings
self.header = "Nexus v3.14.1592 Portal System"
self.rows = 4
self.cols = 5
self.xspacing = 2
self.yspacing = 2
self.topspacing = 3
self.botspacing = 4
self.textsize = 0.5
self.textcolor = colors.white
self.backcolor = colors.black
self.oncolor = colors.lime
self.offcolor = colors.red

return self
