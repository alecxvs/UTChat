Console:Subscribe("s", function( con )
		local str = "Console:"
		for i,txt in ipairs(con) do
			str = str .. " " .. txt
		end
		args = {}
		args.text = str
		args.color = Color(255,210,127)
		args.format = {"color", 1, 8, Color(255,100,0)}
		Events:Fire("NetworkedEvent", {name = "PrintChat", args = args})
		Console:Print(str, Color(255,210,127))
	end )