--[[ Events, man! ]]--

function utlEventManager( event )
	if Client then
		Events:Fire(event.name,event.args)
		--If the event is on the client... just fire it!
	elseif IsValid(event.args.player) then
		local plr = event.args.player
		event.args.player = nil
		Network:Send(plr, "UTLClientEvent", event)
	else
		Network:Broadcast("UTLClientEvent", event)
		--If the event is on the server, pass it on to the client!
	end
end

Events:Subscribe( "UTLClientEvent", utlEventManager)
if Client then
	Network:Subscribe( "UTLClientEvent", utlEventManager) -- ~Multifunctional!~
else
	Console:Subscribe("s", function( con )
		local str = "Console:"
		for i,txt in ipairs(con) do
			str = str .. " " .. txt
		end
		args = {}
		args.text = str
		args.color = Color(255,210,127)
		args.format = {"color", 1, 8, Color(255,100,0)}
		Events:Fire("UTLClientEvent", {name = "PrintChat", args = args})
		Console:Print(str, Color(255,210,127))
	end )
end