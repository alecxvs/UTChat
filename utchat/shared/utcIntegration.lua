function PrintChat(player, text, color)
	Events:Fire("NetworkedEvent", {
		name = "PrintChat", args = {
			text = text,
			color = color,
			player = IsValid(player) and player or nil
		}
	})
end

Events:Subscribe("ModuleLoad", function()
	if UTLib then return end

	if Client then
		function Chat:Print(...) PrintChat(nil, ...) end
	end

	if Server then
		function Chat:Send(...) PrintChat(...) end
		function Chat:Broadcast(...) PrintChat(nil, ...) end
		function Player:SendChatMessage(...) PrintChat(self, ...) end
	end
end)
