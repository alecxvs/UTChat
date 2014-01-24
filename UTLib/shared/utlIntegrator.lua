---------------------------------------------------------------------------------
--      If this file is not in the UTLib module, it is likely a hardlink!      --
--            Keep that in mind if you fiddle with the filesystem.             --
---------------------------------------------------------------------------------
   ----------------------------------------------------------------------------
   --If you are looking to uninstall the UTChat Integrator from your modules,--
   -- consider using the uninstall script that was packaged with the module. --
   ----------------------------------------------------------------------------

function utliChatall(c, ...)
	utliChat(c, nil, ...)
end
function utliChat(c_class, x1, x2, x3)
	local args = {}
	if x3 then
		args = {player = x1, text = x2, color = x3}
	else
		args = {text = x1, color = x2}
	end
	Events:Fire("UTLClientEvent", {name = "PrintChat", args = args})
end
Events:Subscribe("ModuleLoad", function()
	if Client then
			print("Integrated Client")
			Chat.Print = utliChat
	end
	if Server then
			print("Integrated Server")
			Chat.Send = utliChat
			Chat.Broadcast = utliChatall
			Player.SendChatMessage = function(...) utliChat(nil,...) end
	end
end)