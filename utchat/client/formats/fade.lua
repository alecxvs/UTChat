--UText Fade Format--
--[[
Fade Effect
	- type = "Fade"
	- startpos = <number>
	- endpos = <number>
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
Events:Subscribe( "ModulesLoad", function()
	class 'Fade'

	-- Fade Effect Init
	function Fade:__init( startpos, endpos, params )
		Format.__init(self, startpos, endpos)
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

		self.StartTime	= StartTime
		self.Duration		= Duration
		self.StartAlpha 	= StartAlpha
		self.EndAlpha		= EndAlpha
		self.Func			= Func or Easing.linear
		self.RepeatDelay	= Extra.RepeatDelay or 0
		self.Rewind		= Extra.Rewind
		self.AccessParent	= Extra.Override
		self.Terminate   = Extra.Terminate
		
		if Extra.Repeat == true or Extra.Repeat == 1 then
			self.Repetitions	= 0
			self.Repeat 		= true
	elseif Extra.Repeat and Extra.Repeat > 1 then
			self.Repetitions 	= Extra.Repeat
			self.Repeat 		= true
		else
			self.Repetitions 	= 1
			self.Repeat 		= false
		end
		

		if not (type(StartTime)			== "number" and
				type(Duration)			== "number" and
				type(StartAlpha)		== "number" and
				type(EndAlpha)			== "number" and
				type(self.Repetitions) 	== "number" and
				type(self.RepeatDelay) 	== "number") then
			error("Fade format expected numeric parameters") end
		return self
	end

	-- Fade Effect Render
	function Fade:Render( block )
		local timeElapsed, timeEnd
		if os.clock() == self.osclock then goto nocalc else self.osclock = os.clock() end
		if self.StartAlpha > self.EndAlpha then
			self.rewinding = true
			self.Rewind = true
			local s = self.StartAlpha
			self.StartAlpha = self.EndAlpha
			self.EndAlpha = s
		end
		
		if not self.init then
			self.StartTime = os.clock() + self.StartTime
			self.init = true
		end
		timeEnd = self.StartTime + self.Duration
		
		if self.rewinding then
			timeElapsed = (os.clock() - (os.clock() - self.StartTime)*2) - (self.StartTime - self.Duration)
		else
			timeElapsed = os.clock() - self.StartTime
		end
		
		if self.StartTime <= os.clock() and os.clock() <= timeEnd then
			self.alpha = self.Func(timeElapsed, self.StartAlpha, self.EndAlpha, self.Duration)
		elseif self.StartTime > os.clock() then
			self.alpha = self.StartAlpha
		end
		if os.clock() >= timeEnd then
			if not self.Rewind or self.Rewind and self.rewinding then
				if self.Repetitions > 0 then
					self.Repetitions = self.Repetitions - 1
					self.Repeat = self.Repetitions > 0
				end
				if self.Repeat then
					self.StartTime = timeEnd + self.RepeatDelay
					self.rewinding = false
				end
				self.alpha = self.Rewind and self.StartAlpha or self.EndAlpha
				if self.Terminate then self = nil return end
			else
				self.rewinding = true
				self.StartTime = timeEnd
				self.alpha = self.EndAlpha
			end
		end
		::nocalc::
		if self.AccessParent then
			block.parent.alpha = self.alpha
		else
			block.color.a = self.alpha
		end
	end

	UText.RegisterFormat( Fade, "fade" )
end)