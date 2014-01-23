--UTChat--
-- > The work in this file is licensed under the Microsoft Reciprocal License (MS-RL)
-- > The license can be found in license.txt accompanying this file
-- Copyright © Alec Sears ("SonicXVe") 2014
class 'UTChat'
UTChat.ModuleName = "UTL Chat Manager"
UTChat.ModuleClass = "UTChat"
UTChat.ModuleDependencies = {"UTLib"}
UTChat.Messages = {}
UTChat.ChatHandlers = {}
local paused = false
local loaded = false
local hidden = false
local keydown = {}
local renderchunk

function UTChat:__init()
	self.Messages = {}
	self.ChatHandlers = {n = 0}
	Events:Subscribe( "PostRender", self, self.Render )
	Events:Subscribe( "KeyDown", self, self.KeyDown )
	Events:Subscribe( "KeyUp", self, self.KeyUp )
	Events:Subscribe( "PrintChat", self, self.PrintChat )
	Events:Subscribe("UTChatDisable", self, self.Disable )
	self:Enable()
	loaded = true
end

function UTChat:Enable()
	events = {
		Events:Subscribe( "PlayerChat", self, self.OnPlayerChat )
	}
end

function UTChat:Disable()
	for i=1,#events do Events:Unsubscribe(events[i]) end
end

function UTChat:RegisterChatHandler( func, priority )
	if not priority then priority = self.ChatHandlers.n + 1 end
	self.ChatHandlers[priority]=func
	if func then self.ChatHandlers.n = self.ChatHandlers.n + 1 end
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
	for i=1,15 do Chat:Print("",Color(0,0,0,0)) end
	utxt:Format( "motion", true, 0, 0.3, {Vector2(0, 20),Vector2(0, -20)}, Easing.outSine)
	utxt:Format( "fade", true, 0, 0.3, 0, 255)
	utxt:Format( "shadow", 1, #utxt.text, -1, -1, 150 )
	utxt.finalcallback = function( ut ) table.remove(self.Messages,ut.MessageID) end
	if paused then utxt.alpha = utxt.alpha * 0.50 end
	if hidden then utxt.alpha = 0 end
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
				m.alpha = (((((-(ix-msgs_fade) * (ix-msgs_fade))/msgremainder + msgremainder))/msgremainder)*(paused and 255*0.5 or 255))
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

function UTChat:KeyDown( args )
	if args.key == 114 and not keydown[114] then
		hidden = not hidden
		for i,m in ipairs(self.Messages) do
			local alp = hidden and 0 or m.oldalpha
			if hidden then m.oldalpha = m.alpha end
			m:Format("fade", true, 0, 0.5, m.alpha, alp, Easing.inOutQuad, {Override = true, Terminate = not hidden})
			m:Optimize()
		end
	end
	
	keydown[args.key] = true
end

function UTChat:KeyUp( args )
	keydown[args.key] = false
end

function UTChat:Render( args ) -- Render Hook
	
	if paused != (Game:GetState() != GUIState.Game) then
		for i,m in ipairs(self.Messages) do m.alpha = m.alpha * (paused and 2 or 0.50) end
		paused = (Game:GetState() != GUIState.Game)
	end
	
	for i,m in ipairs(self.Messages) do
		if i <= msgs_visible then
			m:Render()
		end
	end
end

Events:Subscribe( "UTLibLoaded", function() if not loaded then UTLib.LoadModule( UTChat ) end end)