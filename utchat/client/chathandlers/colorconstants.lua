--UTChat: Color Tags--
--This is a chat handler addition.
--Purpose:  Parse color constants and apply them to text
--================================================================================--

Events:Subscribe("ModulesLoad", function( )
	UTChat.RegisterChatHandler(function( utxt )
		assert((class_info(utxt).name):lower() == "utext", "UTChat Tag Parser failed: Expecting UText object, got "..type(utxt)..": "..(class_info(pColor).name):lower())
		::redo::
		local startindex, color = utxt.text:match("()%(([%a%s]+)%).+")
		do
			if not startindex or not color then goto final end

			local function tchelper(first, rest)
			  return first:upper()..rest:lower()
			end

			local fcolor = color:gsub("(%a)([%w_']*)", tchelper):gsub("(.-)%s(.-)","%1%2")

			utxt:RemoveText(startindex, startindex+#color+1)
			if Color[fcolor] then
				utxt:Format("color", startindex, #utxt.text, Color[fcolor])
			end
			
			goto redo
		end
		::final::
		utxt.optimized = false --ALWAYS ALWAYS unset optimized when changing text or formatting :O
		return utxt
	end, 100)
end)
