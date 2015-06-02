function PrintChat(args)
	Events:Fire("NetworkedEvent", {name = "PrintChat", args = args})
end

Events:Subscribe("ModuleLoad", function()
	if UTLib then return end

	local pcMethod = function(text, color)
		PrintChat({player = player, text = text, color = color or Copy(Color.White)})
	end

	local cpcMethod = function(_c, text, color)
		PrintChat({text = text, color = color})
	end

	if Client then
			Chat.Print = cpcMethod
	end

	if Server then
		Chat.Send = cpcMethod
		Chat.Broadcast = pcMethod
		Player.SendChatMessage = pcMethod
	end
end)
