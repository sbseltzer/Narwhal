
// A

NARWHAL.__Modules = {}

--local WHITELIST = {}
local ModuleFiles = {}
local IncludedModules = {}

// Gets the module data from the global table
local function GetModule( moduleName )
	if !NARWHAL.__Modules[moduleName] then
		--ErrorNoHalt( "Module '"..moduleName.."' is not a registered module.\n" )
		return
	end
	return NARWHAL.__Modules[moduleName]
end

// Global function to include a child module for an optional given parent
function IncludeModule( Module )
	local t = GetModule( Module ) -- Gets the module's table
	if !t then
		error( "The inclusion of Module '"..Module.."' failed!\n" )
	end
	return table.Copy( t ) -- Return a copy of the table.
end

// Resets the Module table
local function ResetModuleTable()
	
	MODULE = {}
	MODULE.Object = {}
	
	MODULE.Name = nil
	MODULE.Title = ""
	MODULE.Author = ""
	MODULE.Contact = ""
	MODULE.Purpose = ""
	
	// Includes a module inside a module. Returns the child module.
	function MODULE.Require( moduleName )
		if !GetModule( moduleName ) then
			error( "The inclusion of Module '"..moduleName.."' failed! Halting dependency tree.\n" )
		end
		return IncludeModule(moduleName)
	end
	
	// Adds a hook for the specified module.
	function MODULE:Hook( hookName, uniqueName, func )
		local self = self or MODULE
		local isMember = false
		for k, v in pairs( self ) do
			if v == func then
				isMember = true
				break
			end
		end
		if isMember then
			hook.Add( hookName, "MODULES."..self.Name..".HOOK."..uniqueName, function( ... ) return func( self, ... ) end )
		else
			hook.Add( hookName, "MODULES."..self.Name..".HOOK."..uniqueName, function( ... ) return func( ... ) end )
		end
	end
	
	// Gets a key value, or sets one if it's nil
	function MODULE:GetKeyValue( key, value )
		if !self.KeyValues and !value then
			ErrorNoHalt( "Module '"..self.Name.."' has no key values.\n" )
			return
		end
		if !self.KeyValues then
			self.KeyValues = {}
		end
		if !self.KeyValues[key] and value then
			self.KeyValues[key] = value
			return value
		end
		return self.KeyValues[key]
	end
	
	// Sets a key value
	function MODULE:SetKeyValue( key, value )
		if !self.KeyValues then
			self.KeyValues = {}
		end
		self.KeyValues[key] = value
	end
	
	function MODULE:GenerateHooks()
		local hooks = hook.GetTable()
		for k, v in pairs( self ) do
			if type(v) == "function" and hooks[k] then
				hook.Add( k, "MODULES."..self.Name..".HOOK.".."BaseFunction_"..k, function( ... ) return v( self, ... ) end )
			end
		end
	end
	
end

// Registers a specific module file
local function RegisterModule( path, state )
	
	if path:find(".") and !path:find(".lua") then return end -- Don't include the "." or ".." folders.
	
	ResetModuleTable() -- Reset the Module table
	
	// Does the actuall including
	local function FinalInclude()
	
		include( path )
		
		if !MODULE then return end
		
		if GetModule( MODULE.Name ) then
			--MsgN( "Module '",MODULE.Name,"' already exists!" )
			return
		end
		
		GenerateObjectRef()
		NARWHAL.__Modules[MODULE.Name] = MODULE
		
		--MsgN( MODULE.Name, "\t", path, "\t", state )
		MsgN("Successfully registered Module '",MODULE.Name,"'!")
		
	end
	
	// Include a clientside module
	local function IncludeOnClient()
		if SERVER then
			AddCSLuaFile( path )
		end
		if CLIENT then
			FinalInclude()
		end
	end
	
	// Include a serverside module
	local function IncludeOnServer()
		if SERVER then
			FinalInclude()
		end
	end
	
	// Include a shared module
	local function IncludeShared()
		if SERVER then
			AddCSLuaFile( path )
		end
		FinalInclude()
	end
	
	if state == "client" then
		IncludeOnClient()
	elseif state == "server" then
		IncludeOnServer()
	elseif state == "shared" then
		IncludeShared()
	end
	
	/*
	for k, v in pairs( MODULE ) do
		if type(v) == "function" then
			if !GetModule( MODULE.Name ).Enabled then
				MODULE.Cached[k] = v
				MODULE[k] = function()
					return false
				end
			else
				MODULE[k] = MODULE.Cached[k]
			end
		end
	end
	*/
	
end

local function PreloadModuleData( path, state )
	
	if path:find(".") and !path:find(".lua") then return end
	
	local function ReadText()
		
		local RawText = file.Read( "../gamemodes/"..path )
		--print("Path = ",path)
		
		local Name
		local namePattern = "MODULE%.Name%s*=%s*\"([%w_]+)\""
		
		for modName in RawText:gmatch( namePattern ) do
			--print("Name = ",modName)
			Name = modName
		end
		
		local mIncludes = {}
		local includesPattern, ipat2 = "MODULE%.Require%s*%b()", "MODULE%.Require%s*%(%s*\"([%w_]+)\"%s*%)"
		local rFunc = "MODULE.Require(\"\""
		local final
		
		for reqModule in RawText:gmatch( ipat2 ) do
			--print("Include = ",reqModule)
			table.insert( mIncludes, reqModule )
		end
		
		ModuleFiles[Name] = { Path = path, State = state, Dependencies = mIncludes }
		
	end
	
	if state == "server" then
		if SERVER then
			ReadText()
			--MsgN("Preloading module data for file '"..path.."' in the "..state.." lua state.")
		end
	elseif state == "client" then
		if SERVER then
			AddCSLuaFile( path )
		end
		if CLIENT then
			ReadText()
			--MsgN("Preloading module data for file '"..path.."' in the "..state.." lua state.")
		end
	elseif state == "shared" then
		if SERVER then
			AddCSLuaFile( path )
		end
		ReadText()
		--MsgN("Preloading module data for file '"..path.."' in the "..state.." lua state.")
	end
	
end

local function LoadGamemodeModules()
	
	local Folder = string.Replace( GM.Folder, "gamemodes/", "" );
	local path, state
	
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/modules/*") ) do
		path = Folder.."/gamemode/modules/"..d
		if d:find( ".lua" ) then
			if d:sub( 1, 3 ) == "cl_" then
				state = "client"
			elseif d:sub( 1, 3 ) == "sv_" then
				state = "server"
			else
				state = "shared"
			end
			PreloadModuleData( path, state )
		elseif d == "client" or d == "server" or d == "shared" then
			for e, f in pairs( file.FindInLua( Folder.."/gamemode/modules/"..d.."/*" ) ) do
				path = Folder.."/gamemode/modules/"..d.."/"..f
				PreloadModuleData( path, state )
			end
		end
	end
	
	MODULE = nil
	
end

// Recursive function for including modules in the correct order.
local function recur( name )
	if !ModuleFiles[name] then
		ErrorNoHalt("Attempting to include an invalid module\n")
		return
	end
	for _, inc in pairs( ModuleFiles[name].Dependencies ) do -- loop through the module's dependencies
		if ModuleFiles[inc] then -- If the include exists
			if !GetModule( inc ) then -- If the include is registered
				recur( inc ) -- Perform these actions on the include's dependencies
			end
		else
			ErrorNoHalt("Attempting to include an invalid module\n")
		end
	end
	RegisterModule( ModuleFiles[name].Path, ModuleFiles[name].State ) -- Include the module
	table.insert( IncludedModules, inc )
end

LoadGamemodeModules() -- Preload them

PrintTable(ModuleFiles)

// Loop through the module files and include their dependencies first
for k, v in pairs( ModuleFiles ) do
	if !table.HasValue( IncludedModules, k ) then
		recur( k )
	end
end

// Run all module Initialize functions if they have one.
for k, v in pairs( NARWHAL.__Modules ) do
	if v.Initialize then
		v:Initialize()
	end
	v:GenerateHooks()
end









