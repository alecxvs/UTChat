--UTLib UText Loader Mechanism--
-- > The work in this file is licensed under the Microsoft Reciprocal License (MS-RL)
-- > The license can be found in license.txt accompanying this file
-- Copyright © Alec Sears ("SonicXVe") 2014
UTL = {}
class 'UTLib'
UTLib.ModuleName = UTLVer or "Unified Text Library (v??)"
UTLib.ModuleClass = "UTLib"
UTLib.PendingModules = {}
UTLib.CommandQueue = {}
function UTLib.LoadModule( tbl )
	table.insert(UTLib.PendingModules, tbl)
	::recheck::
	for k=1,#UTLib.PendingModules do
		local mod = UTLib.PendingModules[k]
		if type(mod) == "table" then
			mod.ModuleName = mod.ModuleName or "Unnamed Module"
			mod.ModuleDependencies = mod.ModuleDependencies or {}
			mod.External = mod.External or false
		else
			mod.ModuleName = pcall(function() if mod.ModuleName then return true end end) and mod.ModuleName or "Unnamed Module"
			mod.ModuleDependencies = pcall(function() if mod.ModuleDependencies then return true end end) and mod.ModuleDependencies or {}
			mod.External = pcall(function() return mod.External end)
		end
		local modname = mod.ModuleClass
		
		local trebuchet = {}
		for i,obj in ipairs(mod.ModuleDependencies) do
			if obj:find(".lua") or obj:find(".luo") then
				trebuchet[obj] = UTLib.FetchFile(obj)
				if trebuchet[obj] then trebuchet.n = (trebuchet.n or 0) + 1 end
			elseif not UTL[obj] then goto failed end
		end
		
		if not mod.External then
			UTL[modname] = mod()
			if mod.ModuleName then modname = mod.ModuleName end
			print ("Loader: Loaded module "..modname)
			Events:Fire(mod.ModuleClass.."Loaded")
		else
			UTL[modname] = mod
			print ("Loader: Loaded external module "..modname)
			Events:Fire(mod.ModuleClass.."Deploy", __ut)
		end
		table.remove(UTLib.PendingModules,k)
		for i,c in ipairs(UTLib.CommandQueue) do
			if c.target == mod.ModuleClass then
				Events:Fire(c.target..c.command)
			end
		end
		goto recheck
		::failed::
	end

end

Events:Subscribe( "UTLibDisable", function ( classname )
	if UTL[classname] then
		Events:Fire(UTL[classname].ModuleName.."Disable")
	else
		table.insert(UTLib.CommandQueue, {target = classname, command = "Disable"})
	end
end)

Events:Subscribe( "UTLibRegisterExternal", function( event )
	local mod = {}
	math.randomseed(os.clock())
	local rand = math.random(10000,40000)
	mod.ModuleName = event.Name or "Unnamed External "..rand
	mod.ModuleClass = event.Class or "anonymous_"..rand
	mod.Dependencies = event.Dependencies or {}
	mod.External = true
	UTLib.LoadModule( mod )
end)

function UTLib.TypeCheck( var, vartype, info )
	if type(var) == "table" then
		for i,f in ipairs(var) do
			assert(class_info(f).name == vartype, "Type check failed:\nExpected type "..vartype..", got "..class_info(f).name..".\nAdditional Info: "..(info or "<none>"))
		end
	else
		assert(class_info(var).name == vartype, "Type check failed:\nExpected type "..vartype..", got "..class_info(var).name..".\nAdditional Info: "..(info or "<none>"))
	end
end

function UTLib:__init()
	--Events:Fire( "UTLibLoaded" )
end

Events:Subscribe( "UTextLoaded", function()
		print("Loader: ** UText Library loaded **")
		UTL["UText"] = UText
		UTLib.LoadModule( UTLib )
end )
Events:Fire( "IsUTextLoaded" )