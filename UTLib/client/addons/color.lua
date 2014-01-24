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
		  Red (number), Green (number), Blue (number), Alpha (number)
		  Red (number), Green (number), Blue (number)
		  ARGB Byte (number)
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
			elseif params.n == 3 then
				assert( type(params[1]) == "number" and
						type(params[2]) == "number" and
						type(params[3]) == "number" ,
				[[UTLib: Error in Color effect: Got three parameters, did not match overload. 
				Expected: R (Number), G (Number), B (Number)
				Got: ]]..type(params[1]).." "..type(params[2]).." "..type(params[3]) )
				
				pColor = Color(params[1],params[2],params[3])
			elseif params.n == 4 then
				assert( type(params[1]) == "number" and
						type(params[2]) == "number" and
						type(params[3]) == "number" and
						type(params[4]) == "number" ,
				[[UTLib: Error in Color effect: Got four parameters, did not match overload. 
				Expected: R (Number), G (Number), B (Number), A (Number)
				Got: ]]..type(params[1]).." "..type(params[2]).." "..type(params[3]).." "..type(params[4]) )
				
				pColor = Color(params[1],params[2],params[3], params[4])
			else
				error( "UTLib: Error in Color effect: Number of parameters does not match any overloads" )
			end
		else
			error( "UTLib: Error in Color effect: This effect requires parameters, see documentation" )
		end
		
		local ueColor = {}
		
		if (class_info(pColor).name):lower() == "color" then
			ueColor.color = pColor
		elseif type(pColor) == "number" then
			ueColor.color = Color(pColor)
		else
			error( [[UTLib: Error in Color effect: Got one parameter, did not match overloads.
					Expected: Color (Color) OR ARGB Byte (number)
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