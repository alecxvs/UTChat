--UText.lua
-- > The work in this file is licensed under the Microsoft Reciprocal License (MS-RL)
-- > The license can be found in license.txt accompanying this file
-- Copyright © Alec Sears ("SonicXVe") 2014

	class 'UText'

	UText.SupportedFormats = {}

	--- Registers a format for convenience (you don't have to supply callback
	--- every time you use an unofficial format.)
	function UText.RegisterFormat(fmt,   ...)
	--							 (Format, string (names))
		if not UText.SupportedFormats then UText.SupportedFormats = {} end
		for i,name in ipairs({...}) do
			UText.SupportedFormats[name] = fmt
		end
	end

	--- Constructor to the UText object
	--- Overloads:
	---		(text, position, duration, <extra>)
	---		(text, position, color, <extra>)
	---		(text, position, duration, color, <extra>)
	function UText:__init(text,   position, ...)
	--					 (string, Vector2,  ...)

		assert(text,"UText Error: Constructor parameter 'text' is required -- was nil")
		self.text = text
		assert(position, "UText Error: Constructor parameter 'position' is required -- was nil")
		assert((class_info(position).name):lower() == "vector2", "UText Error: Constructor parameter 'position' must be a vector")
		self.position = position
		
		self.lifetime = 0
		self.alpha = 255
		self.color = Color.White
		
		self.textsize = 16
		self.scale = 1
		
		self.formats = nil
		self.gformats = nil
		self.optimized = false
		
		self.startTime = os.clock()
		self.endTime = os.clock() + self.lifetime
		
		self.__strtable = {}
		
		for _, v in ipairs({...}) do
			if type(v) == "number" then
				self.duration = v
			elseif class_info(v).name:lower() == "color" then
				self.color = v
			elseif type(v) == "table" then
				for k,d in pairs(v) do
					load("self."..k.." = d")
				end
			else
				error("UText Error: Constructor does not match overloads (Received value of type "..class_info(v).name.." in <extra>)")
			end
		end
	end
	
	
local function escape(s)
	return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'):gsub('%z','%%z'))
end
	
----:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----
--:::::::::::					User Access Function					:::::::::::::--
----:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----


	--Returns the text
	function UText:GetText()
		return self.text
	end

	--Modifies the text (be mindful of existing format tags)
	--                    (string)
	function UText:SetText(text) 
		assert(text,"UText Error: SetText parameter 'text' is required -- was nil")
		self.text = text
		self:Optimize()
	end

	function UText:InsertText(str, index)
		self.text = self.text:sub(1,index-1) .. str .. self.text:sub(index)
		for i,f in ipairs(self.formats) do
			if f.endpos > index then
				f.endpos = f.endpos + #str
				if f.startpos > index then
					f.startpos = f.startpos + #str
				end
			end
		end
	end
	
	function UText:RemoveText(first, index)
		if type(first) == "number" then
			local firstindex, lastindex = first,index
			local length = lastindex - firstindex + 1
			
			self.text = self.text:sub(1,firstindex-1) .. self.text:sub(lastindex+1)
			
			for i,f in ipairs(self.formats) do
				if f.endpos > lastindex then
					f.endpos = f.endpos - length
					if f.startpos > lastindex then
						f.startpos = f.startpos - length
					end
				end
			end
		elseif type(first) == "string" then
			local str = first
			str = escape(str)
			local i = self.text:match(str)
			if i and i > 0 then self:RemoveText(i,#str-1) end
			return i
		else
			error("UText Error: RemoveText expected (firstindex, lastindex) or (string, index)")
		end
	end	
	
	function UText:ReplaceText(text, repl)
		text = escape(text)
		print("^.-()"..text.."().*")
		local firstindex, lastindex = self.text:match("^.-()"..text.."().*")
		if not firstindex or not lastindex then return false end
		local length = lastindex - firstindex + 1
		local diff = #text - #repl
		
		self.text = self.text:gsub("(.-)"..text.."(.-)","%1"..repl.."%2")
		
		if diff != 0 then
			local i = 1
			::refresh::
			while i <= #self.formats do
				f = self.formats[i]
				if f.startpos >= lastindex then
					f.startpos = f.startpos + diff
				elseif lastindex-diff < f.startpos then
					f.startpos = lastindex + diff
				end
					
				if f.endpos >= lastindex then
					f.endpos = f.endpos + diff
				elseif lastindex-diff < f.endpos then
					f.endpos = lastindex + diff
				end
				
				if f.endpos == f.startpos then
					table.remove(self.formats,i)
					goto refresh
				end
				i = i + 1
			end
		end
		return true
	end	
	
	--Returns the duration of the visibility of UText
	function UText:GetDuration() 
		return self.lifetime
	end

	--- Sets the duration of the visibility of UText
	--- Takes a number, optional boolean where if true, the text's lifespan is not restarted to the current time
	--						  (number,   boolean)
	function UText:SetDuration(duration, noReset) 
		assert(type(duration) == "number","UText Error: Invalid parameter to SetDuration -- requires a number, got "..type(duration))
		self.lifetime = duration
		if noReset then
			self.endTime = self.startTime+self.lifetime
		else
			self.startTime = os.clock()
			self.endTime = os.clock()+self.lifetime
		end
	end
	
----:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----
--:::::::::::		Internal Functions (Format, Optimize, Render)		:::::::::::::--
----:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::----
	
	
	function UText:__insertfmt(fmt, global)
		if global then
			fmt.global = true
			self.gformats[fmt.type] = fmt
		else
			table.insert(self.formats, fmt)
		end
	end
	
	--- Adds a format to the UText object
	--- Takes a string as the name of the format to be applied
	--- Unofficial/Unregistered formats can be used given the optional callback FormatCode
	--- (Advanced users can also input an initialized Format table as the only parameter)
	function UText:Format(Format, ...) 
	--					 (string, number, number, <function>)
	--					 (string, boolean, <function>)
	--					 (table)
		if not self.formats then self.formats = {} end
		if not self.gformats then self.gformats = {} end
		self.optimized = false
		local global = false
		local fmtfunction, startindex, endindex
		local paramindex = 3 
		
		if type(select(1,...)) == "boolean" then
			global = true
			paramindex = 2
		else
			startindex = select(1,...)
			assert(startindex,"UText Error: Missing start index in Format")
			endindex = select(2,...)
			assert(endindex,"UText Error: Missing start index in Format")
		end
		
		if type(Format) == "table" and Format.type and Format.startpos
										  and Format.endpos then
			self:__insertfmt(Format, global)
			return
		end
		
		local argbuilder = {n=0}
		for i,par in pairs({...}) do
			if i <= paramindex and not fmtfunction and type(select(i,...)) == "function" then
				fmtfunction = select(i,...)
				paramindex = i+1
			elseif i >= paramindex then
				table.insert(argbuilder,par)
				argbuilder.n = argbuilder.n + 1
			end
		end
		
		if fmtfunction then
			local fmt = fmtfunction(startindex, endindex, argbuilder)
			fmt.type = Format
			self:__insertfmt(fmt, global)
		else
			assert(UText.SupportedFormats and table.count(UText.SupportedFormats) > 0, "UText Error: Attempted to apply formatting without a callback override, no formats are registered.")
			local fmtfunction = UText.SupportedFormats[Format:lower()]
			assert(fmtfunction, "UText Error: Could not format with "..Format..", no supported formats found and no callback override given")
			self:__insertfmt(fmtfunction(startindex, endindex, argbuilder), global)
		end
	end

	-- Runs optimization on a UText object.
	-- This is only necessary if the format table or text was changed.
	function UText:Optimize()
		self.__strtable = {}
		local indexB = #self.text
		local indexA = 1
		local pos = 1
		
		if #self.formats <= 0 then
			self.__strtable = {{ text = self.text , length = #self.text }}
			goto finish
		end
		
		do --Split text into blocks based on boundaries of formats
			::beginning::
			indexB = #self.text
			for k,v in ipairs(self.formats) do
				if indexA == v.startpos and v.startpos == v.endpos then
					indexB = indexA
					break -- You can't get any more precise than a single character ;)
				elseif v.endpos > indexA then
					if v.startpos-1 >= indexA and v.startpos-1 < indexB then
						indexB=v.startpos-1
					elseif v.endpos-1 < indexB then
						indexB=v.endpos
					end
				end
			end
			table.insert(self.__strtable, {
				text=self.text:sub(indexA,indexB),
				length=indexB-indexA + 1
			})
			indexA=indexB+1
			if indexA <= #self.text then goto beginning end
		end
		
		
		::finish::
		for i,block in ipairs(self.__strtable) do --Apply formats (if applicable) and finishing touches to the block
			if #self.formats > 0 then
				block.formats = {}
				for k,v in ipairs(self.formats) do
					if pos >= v.startpos and pos-1+block.length <= v.endpos then
						block.formats[v.type:lower()]=v
					end
				end
			end
			
			block.color 	= Color.White
			block.textsize 	= self.textsize
			block.scale 	= self.scale
			block.position 	= self.position
			block.parent 	= self
			block.alpha		= 255
			
			pos = pos + block.length
			
		end
		self.optimized=true
	end

	-- Call this in a render hook when you are ready to draw your UText object
	function UText:Render() -- Not a hook, just literal	
		if not self.optimized then self:Optimize() return self end
		assert(self.__strtable and self.optimized,"UText Error: Attempted render before optimization!")
		local chars = 0
		local xoffset = 0

		self.parent = self
		for k,fmt in pairs(self.gformats) do
			fmt:Render(self)
		end
		self.parent = nil
		
		for i,block in ipairs(self.__strtable) do
			block.position=self.position+Vector2(xoffset,0)
			local corrected_color = Copy(self.color)
			corrected_color.a = corrected_color.a*(self.alpha/255)
			block.color = corrected_color
			if block.formats then
				for k,fmt in pairs(block.formats) do
					fmt:Render(block)
				end
				xoffset=xoffset+Render:GetTextWidth(block.text,block.textsize,block.scale)
				corrected_color = block.color
				corrected_color.a = corrected_color.a*(block.alpha*(self.color.a*(self.alpha/255)/255)/255)
			end
			Render:DrawText( block.position, block.text, corrected_color, block.textsize, block.scale )
			::noblock::
		end
		if self.lifetime > 0 and os.clock() >= self.endTime then
			if self.finalcallback then
				pcall(self.finalcallback,self)
			else
				return nil
			end
		end
		return self
	end