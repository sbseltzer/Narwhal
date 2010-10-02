
/*---------------------------------------------------------

	Developer's Notes:
	
	We had a serious problem before. We wanted to pcall file
	inclusion, but pcall doesn't work on include. The only 
	function we could find was CompileString, but that 
	required having the plaintext of the file.
	Since Clientside files are added to a cache and then
	cleared from the client's temp folder, there was no way
	for us to effectively read their plain text for protected
	compilation.
	
	We had 3 solutions:
		1. Copy them into text files and send those to the
		   client for reading. Any files that are included
		   and AddCSLuaFile'd to those client files would be read
		   and manually inserted into the code string for compiling.
		2. Send the code directly to the client via datastream
		   for compiling.
		3. Host the files online and use http.Get for compiling.
	None of which were ideal.
	
	We decided to leave it be and just do normal including and
	AddCSLuaFile'ing since it currently poses no significant
	threat to the script.
	
	Special thanks to Ryaga for helping design this system.
	
---------------------------------------------------------*/


// I'm a fan of micro-optimization. I don't care what respectable programmer periodicals say.
// In Lua, calling a local function is performed 30% faster than calling an identical global function.
// Therfore, declaring our globals as locals will mean those functions will run 30% faster than normal.
// The difference can be negligable based on how frequently it's called, but whatever.
local table = table
local file = file
local setmetatable = setmetatable
local unpack = unpack
local error = error
local print = print
local pairs = pairs
local pcall = pcall
local type = type
local ErrorNoHalt = ErrorNoHalt
local Msg = Msg

NARWHAL.__ModuleList = {}

local Loaded, NotLoaded, ClientSideModulePaths, ServerSideModulePaths
local moduleHook = hook -- We don't want devs using the hook library. Instead, they should use the module methods we provided.
local moduleRequire = require -- We may need to prevent workarounds, like bypassing module hooks by doing require("hook") 

// Gets the module table
function NARWHAL.GetModules()
	return NARWHAL.__ModuleList
end

// Gets the module data from the module table
function NARWHAL.GetModule( moduleName, opRef )
	if !moduleName then return end
	if !NARWHAL.__ModuleList[moduleName] then
		error( "NARWHAL.GetModule Failed: Module "..moduleName.." does not exist!\n", 2 )
	elseif NARWHAL.__ModuleList[moduleName].__Disabled then
		Msg( "NARWHAL.GetModule Failed: Module "..moduleName.." is disabled!\n" )
		return
	end
	if opRef then
		return NARWHAL.__ModuleList[moduleName]
	else
		return table.Copy( NARWHAL.__ModuleList[moduleName] )
	end
end

local function CreateModuleTable()
	
	local MODULE = {}
	MODULE.Config = {}
	MODULE.Dependency = {}
	MODULE.AutoHook = true
	MODULE.ManualHook = false
	MODULE.Protect = true
	MODULE.__ModuleHooks = nil
	MODULE.__Dependencies = nil
	MODULE.__Functions = {}
	MODULE.__Protected = { "Require", "GetDependency", "Hook", "UnHook", "HookAll", "UnHookAll", "__Call", "__GenerateFunctionCalls", "__GenerateHooks" }
	
	MODULE.Name = nil
	MODULE.Title = ""
	MODULE.Author = ""
	MODULE.Contact = ""
	MODULE.Purpose = ""
	MODULE.ConfigName = ""
	
	// Includes a module inside a module. Returns the child module.
	function MODULE.Require( moduleName )
		if !MODULE.__Dependencies then
			MODULE.__Dependencies = {}
		end
		table.insert( MODULE.Dependency, moduleName ) -- Table of metatables
		table.insert( MODULE.__Dependencies, moduleName ) -- Table of names
	end
	
	function MODULE:GetDependency( moduleName )
		if !self.Dependency[1] then
			ErrorNoHalt("Narwhal Module Error: Module "..self.Name.." has no Dependencies!")
			return
		end
		if !self.Dependency[moduleName] then
			ErrorNoHalt("Narwhal Module Error: Attempted to get module "..moduleName.." which is not one of module "..self.Name.."'s dependencies!")
			return
		end
		return self.Dependency[moduleName]
	end
	
	// All functions that are direct members of the MODULE table are internally protected.
	function MODULE:__Call( funcName, ... )
		if !NARWHAL.Config.UseModules then
			print( "Attempted to call "..funcName.." on "..self.Name.." while UseModules is false." )
			return
		end
		if table.HasValue( self.__Protected, funcName ) then
			ErrorNoHalt( "Attempted to call function "..funcName.." on "..self.Name.." which is on the Protected list. These functions are not supposed to be called internally with MODULE.__Call!\n" )
			return
		end
		local f = self[funcName] and self.__Functions[funcName]
		if f then
			local t = { pcall( self.__Functions[funcName], ... ) }
			if t[1] then
				table.remove( t, 1 )
				return unpack(t)
			else
				ErrorNoHalt( "Narwhal Module Error in "..self.Name..": "..t[2].."\n" )
			end
		else
			ErrorNoHalt( "Narwhal Module Error for "..self.Name..": Attempt to call MODULE."..funcName.." (function expected, got nil)\n" )
		end
	end
	
	function MODULE:__GenerateFunctionCalls()
		for m, f in pairs( self ) do
			if type( f ) == "function" and !table.HasValue( self.__Protected, m ) then
				self.__Functions[m] = f
				self[m] = function( ... )
					return self:__Call( m, ... )
				end
			end
		end
	end
	
	// Adds a hook for the specified module.
	function MODULE:Hook( hookName, uniqueName, func, hookForReal )
		if !self or type(self) != "table" then print( "Failed to do MODULE:Hook(...). Are you sure you didn't do MODULE.Hook(...)?" ) return end
		if !self.__ModuleHooks then
			self.__ModuleHooks = {}
		end
		local isMember = false
		for k, v in pairs( self ) do
			if type(v) == "function" then
				if v == func then
					isMember = true
					table.insert( self.__Protected, k )
					break
				end
			end
		end
		if isMember then
			func = function( ... ) return func( self, ... ) end
		else
			func = function( ... ) return func( ... ) end
		end
		if !hookForReal then
			table.insert( self.__ModuleHooks, { hookName, uniqueName, func } )
			return
		end
		moduleHook.Add( hookName, "NARWHAL.__ModuleList."..self.Name..".HOOK."..uniqueName, func )
	end
	
	// Removes a hook for the specified module.
	function MODULE:UnHook( hookName, uniqueName, unhookForReal )
		if !self or type(self) != "table" then print( "Failed to do MODULE:UnHook(...). Are you sure you didn't do MODULE.UnHook(...)?" ) return end
		if unhookForReal then
			for k, v in pairs( self.__ModuleHooks ) do
				if v[1] == hookName and v[2] == uniqueName then
					table.remove( self.__ModuleHooks, k )
					break
				end
			end
		end
		moduleHook.Remove( hookName, "NARWHAL.__ModuleList."..self.Name..".HOOK."..uniqueName )
	end
	
	// Generates autohooks.
	function MODULE:__GenerateHooks()
		local hooks = moduleHook.GetTable()
		for k, v in pairs( self ) do
			if type(v) == "function" and hooks[k] then
				self:Hook( k, "BaseFunction_"..k, v )
			end
		end
	end
	
	// Adds a hook for the specified module.
	function MODULE:HookAll()
		if !self.__ModuleHooks then
			return
		end
		for k, v in pairs( self.__ModuleHooks ) do
			moduleHook.Add( v[1], v[2], v[3] )
		end
	end
	
	// Removes a hook for the specified module.
	function MODULE:UnHookAll()
		if !self.__ModuleHooks then
			return
		end
		for k, v in pairs( self.__ModuleHooks ) do
			self:UnHook( unpack( v ), true )
		end
	end
	
	for k, v in pairs( MODULE ) do
		if type( v ) == "function" and !table.HasValue( MODULE.__Protected, k ) then
			table.insert( MODULE.__Protected, k )
		end
	end
	
	return MODULE
	
end

local function SearchModulesFolder( Folder )
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/modules/*" ) ) do
		if d:find( ".lua" ) then
			if SERVER then
				table.insert( ServerSideModulePaths, Folder.."/gamemode/modules/"..d )
			else
				table.insert( ClientSideModulePaths, Folder.."/gamemode/modules/"..d )
			end
		elseif d == "client" then
			for e, f in pairs( file.FindInLua( Folder.."/gamemode/modules/"..d.."/*.lua" ) ) do
				if CLIENT then
					table.insert( ClientSideModulePaths, Folder.."/gamemode/modules/"..d.."/"..f )
				end
			end
		elseif d == "server" then
			for e, f in pairs( file.FindInLua( Folder.."/gamemode/modules/"..d.."/*.lua" ) ) do
				if SERVER then
					table.insert( ServerSideModulePaths, Folder.."/gamemode/modules/"..d.."/"..f )
				end
			end
		end
	end
end

local function HandleUnhandled()

	for k, v in pairs( NotLoaded ) do
		print( "Narwhal Module: " .. v.Name .. " was not loaded because not all dependencies could be found!" )
	end
	
	for k, v in pairs( Loaded ) do
		if ( v.ConfigName and NARWHAL.Config[v.ConfigName] == false ) or ( NARWHAL.Config.Modules[v.Name] and NARWHAL.Config.Modules[v.Name].Enabled == false ) then
			print( "Narwhal Module: "..v.Name.." is disabled." )
			NARWHAL.__ModuleList[v.Name] = {__Disabled = true}
		else
			NARWHAL.__ModuleList[v.Name] = v
			if v.Dependency[1] then
				local meta = {}
				meta.__index = function(table, key) return NARWHAL.__ModuleList[key] end
				setmetatable(v.Dependency, meta)
			end
		end
	end
	
end

local function HandleDependencies( MODULE, nloaded )
	
	if !MODULE then print("invalid module table?") return end
	
	if MODULE.__Dependencies and MODULE.__Dependencies[1] then
		for _, mod in pairs( Loaded ) do
			for k, v in pairs( MODULE.__Dependencies ) do
				if v == mod.Name then
					table.remove( MODULE.__Dependencies, k )
					break
				end
			end
		end
	end
	
	if MODULE.__Dependencies and MODULE.__Dependencies[1] then
		if !nloaded then
			table.insert( NotLoaded, MODULE )
		end
	else
		table.insert( Loaded, MODULE )
		if nloaded then
			NotLoaded[nloaded] = nil
		end
		for k, v in pairs( NotLoaded ) do
			HandleDependencies( v, k )
		end
	end
	
end

local function LoadModules( PathList ) -- PathList is a list of module paths

	for k, v in pairs( PathList ) do
	
		MODULE = CreateModuleTable()
		include( v )
		
		if !MODULE then
			ErrorNoHalt( "Narwhal Module Error: "..v..": The 'MODULE' table is nil! Are there errors in the file?\n" )
		elseif !MODULE.Name then
			ErrorNoHalt( "Narwhal Module Error: "..v..": The 'MODULE.Name' member is nil! Are there errors in the file?\n" )
		elseif MODULE.Name:len() == 0 then
			ErrorNoHalt( "Narwhal Module Error: "..v..": The 'MODULE.Name' member is an empty string! The module name must be more than 0 characters!\n" )
		elseif MODULE.Name:find( "[^%w_]" ) then
			ErrorNoHalt( "Narwhal Module Error: "..v..": The 'MODULE.Name' member contains unsafe characters! The module name may only contain alphanumeric characters and underscores!\n" )
		elseif table.HasValue( Loaded, MODULE ) or NARWHAL.__ModuleList[MODULE.Name] then
			ErrorNoHalt( "Narwhal Module Error: "..v..": Another module named "..MODULE.Name.." has already been loaded! Copy-paste mistake?\n" )
		else
			local exists = false
			for _, m in pairs( Loaded ) do
				if m.Name == MODULE.Name then
					print( "Narwhal Module: "..v..": Module "..MODULE.Name.." already exists. Module author '"..MODULE.Author.."' may be trying to override it in a derivative, so the original module will not be loaded." )
					exists = true
					break
				end
			end
			if !exists then
				Msg("Handling dependencies for Module "..MODULE.Name.."\n")
				HandleDependencies( MODULE, false )
			end
		end
		
	end
	
	HandleUnhandled()
	
end

function IncludeNarwhalModules() -- Global function. Add to shared.lua.
	
	local function InitWrapper()
		
		if !NARWHAL.Config.UseModules then print("Narwhal Modules are disabled.") return end
		
		hook = nil
		function require( modName )
			if modName == "hook" then
				print( "Trying to bypass module hooks are you? You naughty little bastard. Too bad we're smarter than you. ;D" )
				return
			end
			moduleRequire( modName )
		end
		Loaded = {}
		NotLoaded = {}
		ClientSideModulePaths = {}
		ServerSideModulePaths = {}
		
		// This recursively searches your derived gamemodes until we hit a non-narwhal base.
		// That way we can be sure to add all modules from any narwhal-based gamemodes.
		local function findBases( t, der )
			if der then -- This is our derived gamemode, so we will want to add its modules too.
				SearchModulesFolder( t.Folder:sub(11) ) -- Add modules from the derivatives's folder.
			end
			if t.BaseClass and t.Folder:sub(11):lower() != NARWHAL_FOLDER:lower() then -- If our base isn't narwhal yet, then we need to search deeper.
				SearchModulesFolder( t.BaseClass.Folder:sub(11) ) -- Add modules from the base's folder.
				findBases( t.BaseClass, false ) -- Seach our base's base for modules.
			end
		end
		
		findBases( GM or GAMEMODE or gmod.GetGamemode(), true )
		
		if SERVER then
			for k, v in pairs( ClientSideModulePaths ) do
				AddCSLuaFile( v )
			end
			LoadModules( ServerSideModulePaths )
		else
			LoadModules( ClientSideModulePaths )
		end

		for k, v in pairs( NARWHAL.__ModuleList ) do
		
			if v.Config != nil and NARWHAL.Config.Modules[k] then
				NARWHAL.__ModuleList[k].Config = NARWHAL.Config.Modules[k]
			end
			if v.Init != nil then
				v:Init()
			end
			if v.ManualHook == false then
				v:HookAll()
			end
			if v.AutoHook == true then
				v:__GenerateHooks()
			end
			if v.Protect == true then
				v:__GenerateFunctionCalls()
			end
			
		end
		
		MODULE = nil
		Loaded = nil
		NotLoaded = nil
		ClientSideModulePaths = nil
		ServerSideModulePaths = nil
		hook = moduleHook
		require = moduleRequire
		
	end
	
	InitWrapper()
	
end

// GetModuleInfo - Grabs the module info and converts it to a string.
local function GetModuleInfo( modName, member )
	local mod = NARWHAL.__ModuleList[modName]
	if !mod or mod.__Disabled then
		print( "Module "..modName.." is invalid! It may be disabled." )
		return 
	end
	local function searchTable( t, tabs, str )
		tabs = tabs or 0
		str = str or ""
		local tabString = ""
		if tabs > 1 then
			for i = 1, tabs do
				tabString = tabString.."\t"
			end
		end
		for k, v in pairs( t ) do
			if type(v) == "table" then
				str = str..tabString..k..":\n"..searchTable( t, tabs+1 ).."\n"
			else
				str = str..tabString..k.."\t=\t"..tostring(v).."\n"
			end
		end
		return str
	end
	local outInfo = modName..":\n"
	local name, author, contact, purpose, configname, protect, autohook, manhook = mod.Title, mod.Author, mod.Contact, mod.Purpose, mod.ConfigName, mod.Protect, mod.AutoHook, mod.ManualHook
	if member then
		if !mod[member] then
			print( "Module "..modName.." does not have a table member by the name of '"..member.."'!" )
			return
		end
		local mstring = ""
		if type(mod[member]) == "table" then
			mstring = searchTable( mod[member] )
		else
			mstring = tostring( mod[member] )
		end
		print( modName.."["..member.."]:\t"..mstring )
	end
	outInfo = outInfo.."\tModule Name:\t\t"..name.."\n"
	if author and author != "" then
		outInfo = outInfo.."\tAuthor Name:\t\t"..author.."\n"
	end
	if contact and contact != "" then
		outInfo = outInfo.."\tAuthor Contact:\t\t"..contact.."\n"
	end
	if purpose and purpose != "" then
		outInfo = outInfo.."\tModule Purpose:\t\t"..purpose.."\n"
	end
	if configname and configname != "" then
		outInfo = outInfo.."\tModule Config Name:\t"..configname.."\n"
	end
	if protect != nil then
		outInfo = outInfo.."\tProtection Status:\t"..( ( protect and "Protected" ) or "Unprotected" ).."\n"
	end
	if autohook != nil then
		outInfo = outInfo.."\tAutoHook Status:\t"..( ( autohook and "Enabled" ) or "Disabled" ).."\n"
	end
	if manhook != nil then
		outInfo = outInfo.."\tManualHook Status:\t"..( ( manhook and "Enabled" ) or "Disabled" ).."\n"
	end
	if mod.Config and table.Count( mod.Config ) >= 1 then
		outInfo = outInfo.."\tModule Config:\n"..searchTable( mod.Config, 2 ).."\n"
	end
	if mod.Dependency and table.Count( mod.Dependency ) >= 1 then
		outInfo = outInfo.."\tModule Dependencies:\n"..searchTable( mod.Dependency, 2 ).."\n"
	end
	return outInfo
end

// ConCommand "narwhal_module": Prints a list of registered modules and their info in console when there are no args.
// If you specify a module name as the first arg, it will only print that module's info.
// If you specify a table member as the second arg, it will only print the data from that member of the specified module in console.
local function ListModules( ply, cmd, args )
	if args[1] and NARWHAL.GetModule( args[1], true ) then
		print( GetModuleInfo( args[1], args[2] ) )
	else
		local str = "Listing Narwhal Modules:\n"
		local info
		for k, v in pairs( NARWHAL.GetModules() ) do
			info = GetModuleInfo( k )
			if info then
				str = str..info.."\n"
			end
		end
		print(str)
	end
end
concommand.Add( "narwhal_module", ListModules )


