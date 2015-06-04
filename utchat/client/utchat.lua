--UTChat--
-- > The work in this file is licensed under the Microsoft Reciprocal License (MS-RL)
-- > The license can be found in license.txt accompanying this file
-- Copyright � Alec Sears ("SonicXVe") 2014
class 'UTChat'
local paused = false
local loaded = false
local chat_enabled = false
local keydown = {}
UTChat.ChatHandlers = {n=0}
UTChat.Instances = {}

function UTChat:__init()
	self.Messages = {}
	if not UTChat.ChatHandlers then UTChat.ChatHandlers = {n = 0} end
	Events:Subscribe( "PostRender", self, self.Render )
	Events:Subscribe( "PrintChat", self, self.PrintChat )
	Events:Subscribe("UTChatDisable", self, self.Disable )
	table.insert(UTChat.Instances,self)
	self:Enable()
	loaded = true
end

function UTChat.Enable()
	for i,chat in pairs(UTChat.Instances) do
		chat.eventPlayerChat = Events:Subscribe( "PlayerChat", chat, chat.OnPlayerChat )
	end
end

function UTChat.Disable()
	for i,chat in ipairs(UTChat.Instances) do Events:Unsubscribe(chat.eventPlayerChat) end
end

function UTChat.RegisterChatHandler( func, priority )
	if not priority then priority = UTChat.ChatHandlers.n + 1 end
	UTChat.ChatHandlers[priority]=func
	if func then UTChat.ChatHandlers.n = UTChat.ChatHandlers.n + 1 end
end

function UTChat:PassthroughHandlers( utxt, handlers )
	local err = ""
	for i,v in pairs(handlers) do
		if not utxt then return end
		if v and type(v) == "function" then
			local pass, xtxt = pcall(v,utxt)
			if pass then
				utxt = xtxt
			else
				if not xtxt then
					err = "Handler did not return UText object, complain to the handler's creator"
				else err = xtxt end
				print("- UTChat Warning: Chat Handler failed: "..tostring(v).." parsing \n"..utxt.text.."\n- Error message: "..err.."\n- As a result, the handler had no effect.")
			end
		end
	end
	return utxt
end

local msgs_fade = 10 -- After these many messages, start to fade them out
local msgs_visible = 20 -- You can change this to how many messages you want on the screen at once
local msgs_removeafter = 50 -- Messages are removed from memory after these many come after it

function UTChat:PostMessage( utxt )
	if utxt.nochathandling then goto skip end
	utxt = self:PassthroughHandlers( utxt, self.ChatHandlers )
	if not utxt then return end

	::skip::
	for i=1,15 do Chat:Print("", Color(0,0,0,0)) end

	utxt:Format( "motion", true, 0, 0.3, {Vector2(0, 20),Vector2(0, -20)}, Easing.outSine)
	if chat_enabled then
		utxt:Format( "fade", true, 0, 0.3, 0, utxt.init_alpha, Easing.inOutQuad, {Terminate = true})
	else
		utxt.color.a = 0
	end
	utxt:Format( "shadow", 1, #utxt.text, -1, -1, 150 )

	utxt.finalcallback = function( ut ) table.remove(self.Messages,ut.MessageID) end
	if paused then utxt.alpha = utxt.alpha * 0.50 end
	table.insert(self.Messages, 1, utxt)

	for ix,m in ipairs(self.Messages) do
		m.MessageID = ix
		local pos = Vector2(30,(Render.Height*0.8)-((ix-1)/10*160))
		if ix == 1 then
			m.position = pos
		else
			m:MoveTo(pos,0.3,Easing.outSine)
			m:Optimize()
		end

		if ix > msgs_fade then
			if ix > msgs_removeafter then
				m:SetDuration(0.1)
			else
				local msgremainder = (msgs_visible-msgs_fade)
				m.init_alpha = ((((-(ix-msgs_fade) * (ix-msgs_fade))/msgremainder + msgremainder))/msgremainder) * 255
				m.alpha = m.init_alpha * (paused and 0.5 or 1)
			end
		end
	end
end

function UTChat:OnPlayerChat( args )
	if args.utlignore then return true end
	if args.text:sub(1,1) == "/" then
		args.utlignore = true
		Events:Fire("PlayerChat", args)
		return false
	end
	--local namefiller = ""
	--for i=1,#args.player:GetName() do namefiller = namefiller .. "." end
	--utxt = UText(namefiller .. ": " .. args.text,Vector2(30,(Render.Height*0.80)))
	utxt = UText(args.player:GetName() .. ": " .. args.text,Vector2(30,(Render.Height*0.80)))
	math.randomseed(FNV(args.player:GetName()))
	utxt:Format( "color", 1, #( args.player:GetName() ) + 1,Color( 150 + math.random( 100 ), 150 + math.random( 100 ), 150 + math.random( 100 ) ) )
	self:PostMessage(utxt)
	--utxt.text = self.Messages[1].text:gsub("%.-(:.*)",args.player:GetName().."%1")
	return false
end

function UTChat:PrintChat( args )
	local alpha = args.alpha or 255
	local duration = args.duration or 0
	local color = args.color or Color(255,255,255,255)
	if alpha <= 0 or color.a <= 0 then return end
	local utxt = UText(args.text,Vector2(30,(Render.Height*0.85)),duration,color,{alpha=alpha, nochathandling = args.noparse or false})
	if args.format then args.formats = {args.format} end
	if args.formats then
		for i, fmt in pairs(args.formats) do
			utxt:Format(table.unpack(fmt))
		end
	end
	self:PostMessage(utxt)
end

function UTChat:ToggleChat( enabled )
	for i,m in ipairs(self.Messages) do
		local end_alpha = enabled and m.init_alpha or 0
		m:Format("fade", true, 0, 0.5, m.color.a, end_alpha, Easing.inOutQuad, {Terminate = true})
		m:Optimize()
	end
	chat_enabled = enabled
end

local render_ok = true
local render_last = 1

function UTChat:Render( args ) -- Render Hook
	local message_start = 1
	if not render_ok then
		print("Warning: Last render was not complete! Failed render on message "..render_last)
		message_start = render_last
	end
	if (Chat:GetUserEnabled() and Chat:GetEnabled()) != chat_enabled then self:ToggleChat(Chat:GetUserEnabled() and Chat:GetEnabled()) end
	if paused != (Game:GetState() != GUIState.Game) then
		for message_start,m in ipairs(self.Messages) do
			m.alpha = paused and m.init_alpha or
			chat_enabled and (m.init_alpha * 0.50) or 0
		end
		paused = (Game:GetState() != GUIState.Game)
	end

	for i,m in ipairs(self.Messages) do
		if i <= msgs_visible then
			m:Render()
		end
	end
end

utchat = UTChat()
Events:Subscribe("UTChatInstalled",function() utchat:Enable() end)
Events:Subscribe("UTChatEnable", UTChat.Enable)
Events:Subscribe("UTChatDisable", UTChat.Disable)
