--UText Motion Format--
--[[
Motion Effect
	- type = "Motion"
	- startpos = <number>
	- endpos = <number>
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


Events:Subscribe( "ModulesLoad", function()
	function UText:MoveTo(position, ...)
		print("Move to ",position.x," ",position.y)
		self:Move(position - self.position, ...)
	end
	function UText:Move(offset, duration, func)
		self:Format("motion",true,0,duration or 1,offset,func or Easing.linear)
	end

	UText.RegisterFormat( Motion, "motion" )
end)

class 'Motion'

	-- Motion Effect Init
	function Motion:__init( startpos, endpos, params )
		Format.__init(self, startpos, endpos)
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
				self.Offset = Offset[1]
				Offset = Offset[2]
			end
		end

		self.StartTime		= StartTime
		self.Duration		= Duration
		self.Offset 		= self.Offset or Vector2(0,0)
		self.MoveOffset		= Offset
		self.Func			= Func or Easing.linear
		self.RepeatDelay	= 0 or Extra.RepeatDelay
		self.Rewind			= Extra.Rewind
		
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
		
		self.Actual = Extra.Actual or false
		

		if not (type(StartTime)			== "number" and
				type(Duration)			== "number" and
				type(self.Repetitions) 	== "number" and
				type(self.RepeatDelay) 	== "number") then
			error("Motion format expected numeric parameters") end
	end

	-- Motion Effect Render
	function Motion:Render( block )
		if os.clock() == self.clock then block.position = (block.vposition + self.vec) return else self.clock = os.clock() end
		if not self.init then
			self.StartTime = os.clock() + self.StartTime
			block.vposition = block.position + self.Offset
			self.init = true
		end
		if not self.global then
			block.vposition = block.position
		end
		
		local timeElapsed
		local timeEnd = self.StartTime + self.Duration
		
		if self.rewinding then
			timeElapsed = (os.clock() - (os.clock() - self.StartTime)*2) - (self.StartTime - self.Duration)
		else
			timeElapsed = os.clock() - self.StartTime
		end
		
		if self.StartTime <= os.clock() and os.clock() <= timeEnd then
			self.vec = Vector2(
			self.MoveOffset.x != 0 and
			  self.Func(timeElapsed, 0, self.MoveOffset.x, self.Duration) or 0 ,
			self.MoveOffset.y != 0 and
			  self.Func(timeElapsed, 0, self.MoveOffset.y, self.Duration) or 0 )
			block.position = block.vposition + self.vec
		end
		if os.clock() >= timeEnd then
			if not self.Rewind or self.Rewind and self.rewinding then
				self.rewinding = false
				if self.Repetitions > 0 then
					self.Repetitions = self.Repetitions - 1
					self.Repeat = self.Repetitions > 0
				end
				if self.Repeat then
					self.StartTime = timeEnd + self.RepeatDelay
				end
				block.position = block.vposition + self.vec
			else
				self.rewinding = true
				self.StartTime = timeEnd
				block.position = block.vposition
			end
		end
	end