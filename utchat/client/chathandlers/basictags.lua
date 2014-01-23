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
		local startindex, tagtype, tagparams, endindex = str:match(".-()%[(%a-)=?(.-)%].-()%[/%2%]")
		do
			if not startindex or not tagtype or not tagparams or not endindex then goto final end
			local taglength = 2+#tagtype
			if tagparams and tagparams != "" then taglength = taglength + 1 + #tagparams end
			if UText.SupportedFormats[tagtype:lower()] then
				local paramtable = {}
				local paramiter = string.gmatch(tagparams,"%p?(%-?%w+)")
				for p in paramiter do
					--Determine if number or not
					local num = tonumber(p)
					if num then p = num end
					table.insert(paramtable,p)
				end
				paramtable.n = #paramtable
				local pass, fmt = pcall(UText.SupportedFormats[tagtype:lower()], startindex, endindex-1, paramtable)
				
				
				if pass then
					local scrape = {{startindex, startindex+taglength-1},{endindex,endindex+2+#tagtype}}
					table.insert(formats, fmt)
					for i,f in ipairs(formats) do
						if f.endpos > startindex then
							local offset = scrape[1][2] - scrape[1][1] + 1
							f.endpos = f.endpos - offset
							if f.startpos > startindex then
								f.startpos = f.startpos - offset
							end
							if f.endpos > endindex then
								offset = scrape[2][2] - scrape[2][1] + 1
								f.endpos = f.endpos - offset
								if f.startpos > endindex then
									f.startpos = f.startpos - offset
								end
							end
						end
					end
				else
					print("Format parse error: "..fmt)
				end
			end
			local strcheck = str
			str = str:gsub("(.-)%["..escape(tagtype).."=?"..escape(tagparams).."%](.-)%[/"..escape(tagtype).."%]","%1%2")
			if strcheck == str then
				error("Attempted to gsub (.-)%["..escape(tagtype).."=?"..escape(tagparams).."%](.-)%[/"..escape(tagtype).."%]")
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