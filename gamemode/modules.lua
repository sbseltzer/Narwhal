
/*---------------------------------------------------------

	Developer's Notes:
	
	We had a serious problem before. Since Clientside files
	are added to a cache and then deleted from the client's
	temp folder, there was no way for us to read their
	plain text for dependency detection.
	
	We had 3 solutions:
		1. Copy them into text files and send those to the
		   client for later reading. Any files that are included
		   and AddCSLuaFile'd to those client files would be read
		   and manually inserted into the code string for compiling.
		2. Send the code directly to the client via datastream
		   for compiling.
		3. Host the files online and use http.Get for compiling.
	
	We chose none-of-the-above for the time being. For now
	we will just be including and AddCSLuaFile'ing since
	it currently poses no significant threat to the script.
	
	Instead we just load the files and detect the dependencies
	through tables and then load in the appropriate order.
	
	1. We search the modules folder for clientside, serverside, and shared modules
	2. We add their paths to the respective tables, adding shared ones to both client and server path tables.
	3. We load the modules in the clientside and serverside paths table on gamemode load by reading the serverside code directly from the lua files.
	4. Any files that don't have all their dependencies loaded get added to a table for later handling, and then loading as soon as all their dependencies exist.
	5. This is repeated until all valid files are loaded.
	
	Thank you Ryaga for helping with this system.

---------------------------------------------------------*/


NARWHAL.__ModuleList = {}

local Loaded, NotLoaded, ClientSideModulePaths, ServerSideModulePaths
local moduleHook = hook -- We don't want devs using the hook library. Instead, they should use the module methods we provided.

// Gets the module table
function NARWHAL.GetModules()
	return NARWHAL.__ModuleList
end

// Gets the module data from the module table
function NARWHAL.GetModule( moduleName )
	if !NARWHAL.__ModuleList[moduleName] then
		error( "NARWHAL.GetModule Failed: Module "..moduleName.." does not exist!\n", 2 )
	elseif NARWHAL.__ModuleList[moduleName].__Disabled then
		error( "NARWHAL.GetModule Failed: Module "..moduleName.." is disabled!\n", 2 )
	end
	return NARWHAL.__ModuleList[moduleName]
end

local function CreateModuleTable()
	
	local MODULE = {}
	MODULE.Config = {}
	MODULE.AutoHook = true
	MODULE.Dependency = {}
	MODULE.__ModuleHooks = nil
	MODULE.__Dependencies = nil
	MODULE.__Functions = {}
	MODULE.__Protected = { "Init", "Require", "GetDependency", "Hook", "UnHook", "HookAll", "UnHookAll", "__Call", "__GenerateFunctionCalls", "__GenerateHooks" }
	
	MODULE.Name = nil
	MODULE.Title = ""
	MODULE.Author = ""
	MODULE.Contact = ""
	MODULE.Purpose = ""
	MODULE.ConfigName = ""
	MODULE.Protect = true
	
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
		local self = self or MODULE
		if !self.__ModuleHooks then
			self.__ModuleHooks = {}
		end
		if !hookForReal then
			table.insert( self.__ModuleHooks, { hookName, uniqueName, func } )
			return
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
			moduleHook.Add( hookName, "NARWHAL.__ModuleList."..self.Name..".HOOK."..uniqueName, function( ... ) return func( self, ... ) end )
		else
			moduleHook.Add( hookName, "NARWHAL.__ModuleList."..self.Name..".HOOK."..uniqueName, function( ... ) return func( ... ) end )
		end
	end
	
	// Removes a hook for the specified module.
	function MODULE:UnHook( hookName, uniqueName, unhookForReal )
		local self = self or MODULE
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
				self:Hook( k, "BaseFunction_"..k, v, self.AutoHook )
			end
		end
	end
	
	// Adds a hook for the specified module.
	function MODULE:HookAll()
		local self = self or MODULE
		if !self.__ModuleHooks then
			return
		end
		for k, v in pairs( self.__ModuleHooks ) do
			self:Hook( unpack( v ), true )
		end
	end
	
	// Removes a hook for the specified module.
	function MODULE:UnHookAll()
		local self = self or MODULE
		if !self.__ModuleHooks then
			return
		end
		for k, v in pairs( self.__ModuleHooks ) do
			self:UnHook( unpack( v ), true )
		end
	end
	
	for k, v in pairs( MODULE ) do
		if type( v ) == "function" then
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
			print( "Narwhal Module "..v.Name.." is disabled." )
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
		Loaded = {}
		NotLoaded = {}
		ClientSideModulePaths = {}
		ServerSideModulePaths = {}
		
		local function findBases( t, der )
			if der then -- This is our derived gamemode, so we will want to add its modules too.
				SearchModulesFolder( t.Folder:sub(11) ) -- Add modules from the derivatives's folder.
			end
			if t.BaseClass and t.Folder:sub(11) != "narwhal" then -- If our base isn't narwhal yet, then we need to search deeper.
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
		
			if v.Config and NARWHAL.Config.Modules[k] then
				NARWHAL.__ModuleList[k].Config = NARWHAL.Config.Modules[k]
			end
			if v.Init then
				v:Init()
			end
			if v.Initialize then
				v:Initialize()
			end
			if v.AutoHook then
				v:__GenerateHooks()
			end
			if v.Protect then
				v:__GenerateFunctionCalls()
			end
			
		end
		
		MODULE = nil
		Loaded = nil
		NotLoaded = nil
		ClientSideModulePaths = nil
		ServerSideModulePaths = nil
		hook = moduleHook
		
	end
	
	InitWrapper()
	
end

