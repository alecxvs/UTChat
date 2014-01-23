--UTChat: Basic Tags--
--This is a chat handler addition.
--Purpose:  Parse tags in chat messages that correlate to registered UText formats
--			providing a basic and robust formatting method to players
--================================================================================--
local function escape(s)
	return (s:gsub('[%-%.%+%[%]%(%)%$%^%%%?%*]','%%%1'):gsub('%z','%%z'))
end

local loaded = false
Events:Subscribe("UTChatLoaded", function( )
	if loaded then return end
	loaded = true
	UTL["UTChat"]:RegisterChatHandler(function( utxt )
		assert((class_info(utxt).name):lower() == "utext", "UTChat Tag Parser failed: Expecting UText object, got "..type(utxt)..": "..(class_info(pColor).name):lower())
		local formats = utxt.formats
		if not formats then formats = {} end
		local str = utxt.text
		::redo::
		local startindex, color = str:match("()%((%a-)%)")
		do
			if not startindex or not color then goto final end
			local taglength = 2+#color
			if UText.SupportedFormats[color:lower()] then
				local pass, fmt = pcall(UText.SupportedFormats[color:lower()], startindex, #utxt.text, )
				
				local function tchelper(first, rest)
				  return first:upper()..rest:lower()
				end
				color = color:gsub("(%a)([%w_']*)", tchelper)
				
				if pass then
					local scrape = {startindex, startindex+taglength-1}
					table.insert(formats, fmt)
					for i,f in ipairs(formats) do
						if f.endpos > startindex then
							local offset = scrape[2] - scrape[1] + 1
							f.endpos = f.endpos - offset
							if f.startpos > startindex then
								f.startpos = f.startpos - offset
							end
						end
					end
				else
					print("Format parse error: "..fmt)
				end
			end
			local strcheck = str
			str = str:gsub("(.-)%("..escape(color).."%)(.-)","%1%2")
			if strcheck == str then
				error("Attempted to gsub (.-)%("..escape(color).."%)(.-)","%1%2")
			else
				goto redo
			end
		end
		::final::
		utxt.rawtext = utxt.text
		utxt.text = str
		utxt.formats = formats
		utxt.optimized = false --ALWAYS ALWAYS unset optimized when changing text or formatting :O
		return utxt
	end, 100)
end)