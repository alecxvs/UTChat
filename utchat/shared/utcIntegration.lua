function PrintChat(args)
	Events:Fire("NetworkedEvent", {name = "PrintChat", args = args})
end

Events:Subscribe("ModuleLoad", function()
	if UTLib then return end

	local ptcMethod = function(player, text, color)
		PrintChat({player = player, text = text, color = color or Copy(Color.White)})
	end

	local ctcMethod = function(_c, text, color)
		PrintChat({text = text, color = color})
	end

	if Client then
			Chat.Print = ctcMethod
	end
	if Server then
			Chat.Send = ptcMethod
			Chat.Broadcast = ctcMethod
			Player.SendChatMessage = ptcMethod
	end
end)
