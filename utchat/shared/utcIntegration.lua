function utChatall(c, ...)
	utliChat(c, nil, ...)
end
function utliChat(c_class, x1, x2, x3)
	local args = {}
	if x3 then
		args = {player = x1, text = x2, color = x3}
	else
		args = {text = x1, color = x2}
	end
	Events:Fire("NetworkedEvent", {name = "PrintChat", args = args})
end
Events:Subscribe("ModuleLoad", function()
	if UTLib then return end
	if Client then
			Chat.Print = utliChat
	end
	if Server then
			Chat.Send = utliChat
			Chat.Broadcast = utliChatall
			Player.SendChatMessage = function(...) utliChat(nil,...) end
	end
end)