--[[ Events, man! ]]--

function NetworkEventRouter( event )
	if Client then
		Events:Fire(event.name,event.args)
		--If the event is on the client... just fire it!
	elseif IsValid(event.args.player) then
		local plr = event.args.player
		event.args.player = nil
		Network:Send(plr, "NetworkedEvent", event)
	else
		Network:Broadcast("NetworkedEvent", event)
		--If the event is on the server, pass it on to the client!
	end
end

Events:Subscribe( "NetworkedEvent", NetworkEventRouter)
if Client then
	Network:Subscribe( "NetworkedEvent", NetworkEventRouter) -- ~Multifunctional!~
end