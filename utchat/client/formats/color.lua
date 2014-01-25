--UText Color Format--
--[[
Color Effect
	- type = "Color"
	- startpos = <number>
	- endpos = <number>
  *Custom Parameter*
	* color = args[1-4]
		Overloads:
		  Color instance (Color)
		Conforms to constructors of the Color class, see the JC2-MP Wiki for details:
		  http://wiki.jc-mp.com/Lua/Shared/Color/Constructor
]]--
Events:Subscribe( "ModulesLoad", function()
	
	--Color Effect Init
	class 'utColor'
	
	function utColor:__init( startpos, endpos, params )
		Format.__init(self, startpos, endpos)
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
		
		if (class_info(pColor).name):lower() == "color" then
			self.color = Copy(pColor)
		else
			error( [[UTLib: Error in Color effect: Does not match overloads.
					Expected: Color (Color)
					Got: ]]..type(pColor) )
		end
	end

	--Color Effect Render
	function utColor:Render( block )
		block.color = Copy(self.color)
	end
	
	UText.RegisterFormat( utColor, "color", "colour" )
end)