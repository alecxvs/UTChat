--UText Shadow Format--
--[[
Shadow Effect
	- type = "Color"
	- startpos = <number>
	- endpos = <number>
	- renderfunc = UTLib.Color.Render
  *Custom Parameter* 
	* shadow = args[1-4]
		X Offset = -1 (number), Y Offset = -1 (number), Alpha = 255 (number), Scale = 1 (number)
]]--
local loaded = false
Events:Subscribe( "UTLibLoaded", function()
	if loaded then return end
	loaded = true
	UTLib.Shadow = {}
	
	-- Shadow Effect Init
	UTLib.Shadow.Init =
	function( startpos, endpos, params )
	
		local ueShadow = {}
		local xoffset, yoffset, alpha, scale = table.unpack(params)
		
		ueShadow.type 		= "shadow"
		ueShadow.startpos 	= startpos
		ueShadow.endpos 	= endpos
		ueShadow.renderfunc = UTLib.Shadow.Render
		
		ueShadow.xoffset 	= xoffset or -1
		ueShadow.yoffset 	= yoffset or -1
		ueShadow.alpha 		= alpha or 255
		ueShadow.scale 		= scale or 1
		ueShadow.colormult	= colormult or 0
		
		return ueShadow
	end

	-- Shadow Effect Render
	UTLib.Shadow.Render =
	function( block, effect )
		local scolor = block.color*effect.colormult
		scolor.a = effect.alpha*(block.alpha*(block.parent.color.a*(block.parent.alpha/255)/255)/255)
		Render:DrawText( block.position-Vector2(effect.xoffset,effect.yoffset), block.text, scolor, block.textsize, block.scale*effect.scale )
	end
	
	UText.RegisterFormat( "shadow", UTLib.Shadow.Init )
end)