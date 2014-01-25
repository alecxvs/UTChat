utcConfig = {}

function utcConfig.Write(key, value)
	utc[key] = value
	local f = io.open("utchat.conf","w")
	for k,v in pairs(utc) do
		f:write(k.."="..v.."\n")
	end
	io.close(f)
end

function utcConfig.Load()
	local f = io.open("utchat.conf","r")
	if not f then return end
	for line in f:lines() do
		local key,value = line:match("(%w+)=(.+)")
		utc[key]=value
	end
end

utc = {}
utc.Version = "v1-alpha3"
utc.Installed = false
local state = "main"

Events:Subscribe("ModulesLoad",function()
	utcConfig.Load()
	utc.Installed = utc.Installed == "Yes"
	if not utc.Installed then Events:Fire("utcPreconfig") end
end)

Console:Subscribe("utc", function(args)
	if args[1] == "preconf" then
		state = "preconf"
		Events:Fire("utcPreconfig")
	elseif state != "preconf" then
		
	end
end)

UTChat = {}
function UTChat.Disable()
	Events:Fire("NetworkedEvent",{name = "UTChatDisable", args = {}})
end
function UTChat.Enable()
	Events:Fire("NetworkedEvent",{name = "UTChatDisable", args = {}})
end