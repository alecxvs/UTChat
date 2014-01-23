--UText Motion Format--
--[[
Motion Effect
	- type = "Motion"
	- startpos = <number>
	- endpos = <number>
	- renderfunc = UTLib.Motion.Render
  *Custom Parameter*
	* Motion = args[1-5]
		StartTime = number (From the creation of the UText)
		Duration = number (In seconds)
		MoveOffset = Vector2
					or table: {Vector2, Vector2} (Starting Offset, Move Offset)
		Func = function (Easing function)
		Extra = table (extra parameters)
			Repeat = true (for infinite), number (for limited repetitions), false (no repeat)
			RepeatDelay = number
			Rewind = boolean (rewind the animation after playing)

	OR

		StartTime = number (From the creation of the UText)
		Duration = number (In seconds)
		xOffset = number
		yOffset = number
		Func = function (Easing function)
]]--
local loaded = false
Events:Subscribe( "UTLibLoaded", function()
	if loaded then return end
	loaded = true
	
	function UText.MoveTo(utxt, position, ...)
		utxt:Move(position - utxt.position, ...)
	end
	function UText.Move(utxt, offset, duration, func)
		utxt:Format("motion",true,0,duration or 1,offset,func or Easing.linear)
	end
	
	UTLib.Motion = {}

	-- Motion Effect Init
	UTLib.Motion.Init =
	function( startpos, endpos, params )
		local ueMotion = {}
		local StartTime, Duration, Offset, Func, Extra = table.unpack(params)
		assert(StartTime and Duration and Offset,"UTLib: Error in Motion effect: Required parameters incomplete (Start Time, Duration, Offset)")
		assert(type(Offset) == "table" or class_info(Offset).name:lower() == "vector2" or type(Offset) == "number" and type(Func) == "number", "UTLib: Error in Motion effect: Offset must be Vector2 or two numbers")
		if type(Offset) == "number" and type(Func) == "number" then
			Offset = Vector2(Offset, Func)
			Func = Extra
			Extra = {}
		else
			if Func then
				if type(Func) == "table" then
					Extra = Func
					Func = nil
				end
				if not Extra or type(Extra) != "table" then
					Extra = {}
				end
			end
			if type(Offset) == "table" then
				ueMotion.Offset = Offset[1]
				Offset = Offset[2]
			end
		end

		ueMotion.type			= "Motion"
		ueMotion.startpos		= startpos
		ueMotion.endpos			= endpos
		ueMotion.renderfunc		= UTLib.Motion.Render

		ueMotion.StartTime		= StartTime
		ueMotion.Duration		= Duration
		ueMotion.Offset 		= ueMotion.Offset or Vector2(0,0)
		ueMotion.MoveOffset		= Offset
		ueMotion.Func			= Func or Easing.linear
		ueMotion.RepeatDelay	= 0 or Extra.RepeatDelay
		ueMotion.Rewind			= Extra.Rewind
		
		if Extra.Repeat == true or Extra.Repeat == 1 then
			ueMotion.Repetitions	= 0
			ueMotion.Repeat 		= true
	elseif Extra.Repeat and Extra.Repeat > 1 then
			ueMotion.Repetitions 	= Extra.Repeat
			ueMotion.Repeat 		= true
		else
			ueMotion.Repetitions 	= 1
			ueMotion.Repeat 		= false
		end
		
		ueMotion.Actual = Extra.Actual or false
		

		UTLib.TypeCheck({StartTime,Duration,ueMotion.Repetitions,ueMotion.RepeatDelay}, "number", "In Motion format initialization")
		return ueMotion
	end

	-- Motion Effect Render
	UTLib.Motion.Render =
	function( block, effect )
		if os.clock() == effect.clock then block.position = (block.vposition + effect.vec) return else effect.clock = os.clock() end
		if not effect.init then
			effect.StartTime = os.clock() + effect.StartTime
			block.vposition = block.position + effect.Offset
			effect.init = true
		end
		if not effect.global then
			block.vposition = block.position
		end
		
		local timeElapsed
		local timeEnd = effect.StartTime + effect.Duration
		
		if effect.rewinding then
			timeElapsed = (os.clock() - (os.clock() - effect.StartTime)*2) - (effect.StartTime - effect.Duration)
		else
			timeElapsed = os.clock() - effect.StartTime
		end
		
		if effect.StartTime <= os.clock() and os.clock() <= timeEnd then
			effect.vec = Vector2(
			effect.MoveOffset.x != 0 and
			  effect.Func(timeElapsed, 0, effect.MoveOffset.x, effect.Duration) or 0 ,
			effect.MoveOffset.y != 0 and
			  effect.Func(timeElapsed, 0, effect.MoveOffset.y, effect.Duration) or 0 )
			block.position = block.vposition + effect.vec
		end
		if os.clock() >= timeEnd then
			if not effect.Rewind or effect.Rewind and effect.rewinding then
				effect.rewinding = false
				if effect.Repetitions > 0 then
					effect.Repetitions = effect.Repetitions - 1
					effect.Repeat = effect.Repetitions > 0
				end
				if effect.Repeat then
					effect.StartTime = timeEnd + effect.RepeatDelay
				end
				block.position = block.vposition + effect.vec
			else
				effect.rewinding = true
				effect.StartTime = timeEnd
				block.position = block.vposition
			end
		end
	end

	UText.RegisterFormat( "motion", UTLib.Motion.Init )
end)