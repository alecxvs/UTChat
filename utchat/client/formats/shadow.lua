--UText Shadow Format--
--[[
Shadow Effect
	- type = "Shadow"
	- startpos = <number>
	- endpos = <number>
  *Custom Parameter* 
	* shadow = args[1-4]
		X Offset = -1 (number), Y Offset = -1 (number), Alpha = 255 (number), Scale = 1 (number)
]]--

Events:Subscribe( "ModulesLoad", function()
	class 'Shadow'
	
	-- Shadow Effect Init
	function Shadow:__init( startpos, endpos, params )
		Format.__init(self, startpos, endpos)
		local xoffset, yoffset, alpha, scale = table.unpack(params)
		
		self.xoffset 	= xoffset or -1
		self.yoffset 	= yoffset or -1
		self.alpha 		= alpha or 255
		self.scale 		= scale or 1
		self.colormult	= colormult or 0
	end

	-- Shadow Effect Render
	function Shadow:Render( block )
		local scolor = block.color * self.colormult
		scolor.a = self.alpha*(block.alpha*(block.parent.color.a*(block.parent.alpha/255)/255)/255)
		Render:DrawText( block.position - Vector2( self.xoffset, self.yoffset ), block.text, scolor, block.textsize, block.scale * self.scale )
	end
	
	UText.RegisterFormat( Shadow, "shadow" )
end)