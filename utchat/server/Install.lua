local mode = "preconf"
local prompt

local modules = {n=0}
local install_queue = {n=0}
local uninstall_queue = {n=0}
local custom_queue = {}
local scalp_queue = {}
local con

Events:Subscribe("utcPreconfig",function()
	if not Config:GetValue("Server","IKnowWhatImDoing") then
		print([[
************************************************************************************************
************************************************************************************************
	UTChat's module is installed, but not properly integrated! Please enable 'IKnowWhatImDoing'
	in your server config. You may want to disable it again when you're done here.
	
	If you installed integration manually, enter 'utc ok' and UTChat will be enabled.
************************************************************************************************
************************************************************************************************]])
con = Console:Subscribe("utc", function(a)
	if a[1] == "ok" then
		UTChat.Enable()
		Console:Unsubscribe(con)
		utcConfig.Write("Installed","Yes")
	end
end)
	return
	else
		local dir = io.directories("../")
		for i,d in ipairs(dir) do
			if d:sub(1,1) != "." then
				print("Found ",d)
				modules[d]=true
			end
		end
		modules.n = #dir
		PrintScreen()
		con = Console:Subscribe("utc", OnCommand)
	end
end)

function OnCommand (args)
	if prompt then
		prompt(args)
		prompt = nil
	return end
	if args[1] == "mode" then
		mode = args[2]
		PrintScreen()
	elseif args[1] == "screen" then
		PrintScreen()
	elseif args[1] == "su" then
		local x = {"Philpax in charge of OOP ahueaheuaheue",
			"Patawic codes bugs",
			"Tycoonman500 uses svn",
			"Woet pls",
			"Jman100 doesn't lua :c",
		}
		print(x[math.random(5)])
	else
		local cmd = args[1]
		table.remove(args,1)
		local str = ""
		for i,s in ipairs(args) do str = str .. s end
		if mode == "install" or mode == "install-adv" then
			if cmd == "install" and mode == "install" then
				AutoInstall()
			else
				if cmd == "add" then
					if install_queue[str] then
						print("This module is already in the queue")
					elseif not modules[str] then
						print("Unrecognized module")
					else
						install_queue[str] = true
						install_queue.n = install_queue.n + 1
					end
				elseif cmd == "compat" then
					table.remove(args,1)
					if install_queue[str] then
						print("This module is already in the queue")
					elseif not modules[str] then
						print("Unrecognized module")
					else
						install_queue[str] = CheckCompat(str) and str or true
					end
				elseif cmd == "shim" then
					if custom_queue[str] then
						print("File already shimming")
					else
						local file = io.open(str)
						if file then
							custom_queue[str] = true
							io.close(file)
						else
							print("Error: file does not exist")
						end
					end
				elseif cmd == "integrate" then
					Install()
				else
					goto err
				end
			end
		elseif mode == "uninstall" or mode == "uninstall-adv" then
			if cmd == "uninstall" and mode == "uninstall" then
				AutoUninstall()
			else
				if cmd == "rem" then
					if uninstall_queue[str] then
						print("This module is already in the queue")
					elseif not modules[str] then
						print("Unrecognized module")
					else
						uninstall_queue[str] = true
						uninstall_queue.n = uninstall_queue.n + 1
					end
				elseif cmd == "scalp" then
					if scalp_queue[str] then
						print("File already scalping")
					else
						local file = io.open(str)
						if file then
							scalp_queue[str] = true
							io.close(file)
						else
							print("Error: file does not exist")
						end
					end
				elseif cmd == "unintegrate" then
					Uninstall()
				else
					goto err
				end
			end
		elseif cmd == "update" then
			print("Not yet implemented")
		else
			goto err
		end
	end
	goto fin
	::err::
	print("Unknown command, type 'utc screen' to restore the help display")
	::fin::
end

function PrintScreen()
	if mode == "install" or mode == "install-adv" then print([[ 
\============================================\
|	UTChat Installation Mode ]]..utc.Version..[[ 
/============================================/ 
]] 
..( mode == "install" and
[[	Easy installation:
		utc install
	
	]] or "")..
	[[Advanced Users:
	You can choose which modules to integrate and
	apply compatability patches to certain others.
	
		utc add <module>
			Add a module to install queue
			
		utc compat <module>
			Install patch for module (if exists)
			
		utc shim <path>
			Also install custom script
		
		utc integrate
			Install for big boys
	
	Remember that if you run just 'utc install'
	it will automatically install to every
	module and apply compatability, disregarding
	any settings you may apply. Use INTEGRATE if
	you set advanced parameters.]])
	elseif mode == "uninstall" or mode == "uninstall-adv" then print([[ 
\============================================\
|	UTChat (Un)Installation Mode ]]..utc.Version..[[ 
/============================================/ 
]] 
..( mode == "uninstall" and
[[	Easy uninstallation:
		utc uninstall
	
	]] or "")..
	[[Advanced Users:
	You can choose which modules to unintegrate and
	remove patches and custom scripts as well.
	
		utc rem <module>
			Queue removal of integration or patch
			
		utc scalp <name>
			Also remove custom script
		
		utc unintegrate
			Uninstall for big boys
	
	Remember that if you run just 'utc install'
	it will automatically install to every
	module and apply compatability, disregarding
	any settings you may apply. Use INTEGRATE if
	you set advanced parameters.]])
	elseif mode == "preconf" then print([[ 
\============================================\
|	UTChat Pre-Configuration ]]..utc.Version..[[ 
/============================================/
	Choose an option:
		utc mode install
		utc mode uninstall
		utc mode preconf (return to this screen)
		utc update
	
	Suffix any mode with -adv (i.e. install-adv) to
	restrict commands to advanced user commands only
	(so you don't accidentally auto-install if you
	don't want to).
	
	Update will automatically update any integration
	or compatability scripts found installed, there
	are no advanced commands for it.]])
	else
		print("Error: Attempted to render screen but no mode is known. Please return to 'preconf' mode.")
	end
end

function AutoInstall()
	install_queue = Copy(modules)
	Install()
end

function Install()
	io.write("\n\n")
	io.write("Preparing to install UTChat")
	local dotindex = 0
	local function dotcalc(position,total)
		if position >= dotindex then
			if dotindex != 0 then
				io.write(".")
			end
			dotindex = (position/total)*(position+1)	
		end
	end
	local filequeue = {"shared/utcIntegration.lua",table.unpack(custom_queue)}
	local filedata = {}
	local errors = ""
	for i,file in ipairs(filequeue) do
		dotcalc(i,#filequeue)
		local f = io.open(file)
		if f then
			filedata[file] = f:read("*a")
			io.close(f)
		else
			errors = errors .. "Could not access file "..file.."\n"
		end
	end
	io.write("\n"..errors.."\n\nInstalling UTChat")
	dotindex=0
	local i = 1
	for mod,t in pairs(install_queue) do
		if mod != "n" and mod != "utchat" and t then
			if t == true then
				for f,data in pairs(filedata) do
					dotcalc(i,install_queue.n * #filequeue)
					i = i + 1
					io.createdir("../"..mod.."/shared/")
					local file = io.open("../"..mod.."/"..f,"w")
					file:write(data)
					io.close(file)
				end
			end
		end
	end
	utcConfig.Write("Installed","Yes")
	io.write("\n")
	print("Finished!\n\n")
	UTChat.Enable()
	Console:Unsubscribe(con)
	for mod,t in pairs(install_queue) do
		if mod != "utchat" then
			Console:Run("reload "..mod)
		end
	end
end

function AutoUninstall()
	uninstall_queue = Copy(modules)
	Uninstall()
end

function Uninstall()
	io.write("\n\n")
	io.write("Preparing to uninstall UTChat.....")
	local dotindex = 0
	local function dotcalc(position,total)
		if position >= dotindex then
			if dotindex != 0 then
				io.write(".")
			end
			dotindex = (position/total)*(position+1)	
		end
	end
	local filequeue = {"shared/utcIntegration.lua",table.unpack(scalp_queue)}
	local filedata = {}
	local errors = ""
	io.write("\nUninstalling UTChat")
	local i = 1
	for mod,t in pairs(uninstall_queue) do
		if mod != "n" and mod != "utchat" and t then 
			if t == true then
				for i,f in ipairs(filequeue) do
					dotcalc(i,uninstall_queue.n * #filequeue)
					i = i + 1
					
					local file = io.open("../"..mod.."/"..f,"w")
					if file then
						io.close(file)
						local pass, err = os.remove("./scripts/"..mod.."/"..f)
						if not pass then errors = errors .. "\n" .. err end
					end
				end
				RemoveEmptyFolders(mod)
			end
		end
	end
	io.write(errors)
	utcConfig.Write("Installed","No")
	io.write("\n")
	print("Finished!")
	UTChat.Disable()
	mode = "preconf"
	PrintScreen()
end

function RemoveEmptyFolders(path)
	local dir = io.directories("../"..path)
	local count = #dir
	for id,dex in ipairs(dir) do
		if RemoveEmptyFolders(path.."/"..dex) then
			local files = io.files("../"..path.."/"..dex.."/")
			if #files <= 0 then
				count = count - 1
				local pass, err = os.remove("./scripts/"..path.."/"..dex)
				if not pass then errors = errors .. "\n" .. err end
			end
		end
	end
	return count <= 0
end

