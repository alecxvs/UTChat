--Generic Format--
--[[
	- type = <string>
	- startpos = <number>
	- endpos = <number>
]]--

class 'Format'

-- Shadow Effect Init
function Format:__init( startpos, endpos )
	self.startpos = startpos
	self.endpos = endpos
	self.type = class_info(self).name:lower()
end

-- Shadow Effect Render
function Format:Render( block )
	error("Render function not implemented")
end
