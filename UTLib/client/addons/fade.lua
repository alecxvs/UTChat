--UText Fade Format--
--[[
Fade Effect
	- type = "Fade"
	- startpos = <number>
	- endpos = <number>
	- renderfunc = UTLib.Fade.Render
  *Custom Parameter*
	* Fade = args[1-6]
		StartTime = number (From the creation of the UText)
		Duration = number (In seconds)
		StartAlpha = number (0-255)
		EndAlpha = number (0-255)
		Func = function (Easing function)
		Extra = table (extra parameters)
			Repeat = true (for infinite), number (for limited repetitions), false (no repeat)
			RepeatDelay = number
			Rewind = boolean (rewind the animation after playing)
]]--
local loaded = false
Events:Subscribe( "UTLibLoaded", function()
	if loaded then return end
	loaded = true
	UTLib.Fade = {}

	-- Fade Effect Init
	UTLib.Fade.Init =
	function( startpos, endpos, params )
		local ueFade = {}
		local StartTime, Duration, StartAlpha, EndAlpha, Func, Extra = table.unpack(params)
		assert(StartTime and Duration and StartAlpha and EndAlpha,"UTLib: Error in Fade effect: Parameters incomplete (Start Time, Duration, StartAlpha, EndAlpha)")
		if Func then
			if type(Func) == "table" then
				Extra = Func
				Func = nil
			end
			if not Extra or type(Extra) != "table" then
				Extra = {}
			end
		else
			Extra = {}
		end


		ueFade.type			= "Fade"
		ueFade.startpos		= startpos
		ueFade.endpos		= endpos
		ueFade.renderfunc	= UTLib.Fade.Render

		ueFade.StartTime	= StartTime
		ueFade.Duration		= Duration
		ueFade.StartAlpha 	= StartAlpha
		ueFade.EndAlpha		= EndAlpha
		ueFade.Func			= Func or Easing.linear
		ueFade.RepeatDelay	= Extra.RepeatDelay or 0
		ueFade.Rewind		= Extra.Rewind
		ueFade.AccessParent	= Extra.Override
		
		if Extra.Repeat == true or Extra.Repeat == 1 then
			ueFade.Repetitions	= 0
			ueFade.Repeat 		= true
	elseif Extra.Repeat and Extra.Repeat > 1 then
			ueFade.Repetitions 	= Extra.Repeat
			ueFade.Repeat 		= true
		else
			ueFade.Repetitions 	= 1
			ueFade.Repeat 		= false
		end
		

		UTLib.TypeCheck({StartTime,Duration,StartAlpha,EndAlpha,ueFade.Repetitions,ueFade.RepeatDelay}, "number", "In Fade format initialization")
		return ueFade
	end

	-- Fade Effect Render
	UTLib.Fade.Render =
	function( block, effect )
		local timeElapsed, timeEnd
		if os.clock() == effect.osclock then goto nocalc end
		effect.osclock = os.clock()
		
		if effect.StartTime < block.parent.startTime then effect.StartTime = block.parent.startTime + effect.StartTime end
		timeEnd = effect.StartTime + effect.Duration
		
		if effect.rewinding then
			timeElapsed = (os.clock() - (os.clock() - effect.StartTime)*2) - (effect.StartTime - effect.Duration)
		else
			timeElapsed = os.clock() - effect.StartTime
		end
		
		if effect.StartTime <= os.clock() and os.clock() <= timeEnd then
			effect.alpha = effect.Func(timeElapsed, effect.StartAlpha, effect.EndAlpha, effect.Duration)
		elseif effect.StartTime > os.clock() then
			effect.alpha = effect.StartAlpha
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
				alpha = effect.StartAlpha
			else
				effect.rewinding = true
				effect.StartTime = timeEnd
			end
			effect.alpha = effect.EndAlpha
		end
		::nocalc::
		if effect.AccessParent then
			block.parent.alpha = effect.alpha
		else
			block.color.a = effect.alpha
		end
	end

	UText.RegisterFormat( "fade", UTLib.Fade.Init )
end)