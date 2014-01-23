--UText Color Format--
--[[
Color Effect
	- type = "Color"
	- startpos = <number>
	- endpos = <number>
	- renderfunc = UTLib.Color.Render
  *Custom Parameter*
	* color = args[1-4]
		Overloads:
		  Color instance (Color)
		Conforms to constructors of the Color class, see the JC2-MP Wiki for details:
		  http://wiki.jc-mp.com/Lua/Shared/Color/Constructor
]]--
local loaded = false
Events:Subscribe( "UTLibLoaded", function()
	if loaded then return end
	loaded = true
	UTLib.Color = {}
	
	--Color Effect Init
	UTLib.Color.Init = function( startpos, endpos, params )
		local pColor = {}
		if params then
			if params.n == 1 then
				pColor = params[1]
			else
				error( "UTLib: Error in Color effect: Number of parameters does not match any overloads" )
			end
		else
			error( "UTLib: Error in Color effect: This effect requires parameters, see documentation" )
		end
		
		local ueColor = {}
		
		if (class_info(pColor).name):lower() == "color" then
			ueColor.color = pColor
		else
			error( [[UTLib: Error in Color effect: Does not match overloads.
					Expected: Color (Color)
					Got: ]]..type(pColor) )
		end
		
		ueColor.type = "color"
		ueColor.startpos = startpos
		ueColor.endpos = endpos
		ueColor.renderfunc = UTLib.Color.Render
		return ueColor
	end

	--Color Effect Render
	UTLib.Color.Render = function( block, effect )
		block.color = effect.color
	end
	
	UText.RegisterFormat( "color", UTLib.Color.Init )
	UText.RegisterFormat( "colour", UTLib.Color.Init )
end)