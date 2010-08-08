
/*
	Module files are read to find their dependencies before being included.
	Their name, path, state, and dependencies are written to a table. 
	Global Module table is set up.
	Each module is loaded and any dependencies are loaded first in a recursive function.
*/

local hook = hook
local file = file
local table = table
local string = string
local type = type
local error = error
local pcall = pcall
local pairs = pairs
local ErrorNoHalt = ErrorNoHalt
local AddCSLuaFile = AddCSLuaFile
local SERVER = SERVER
local CLIENT = CLIENT

NARWHAL.__Modules = {}

local ModuleFiles = {}
local IncludedModules = {}
local FailedModules = {}
local moduleHook = hook

// Gets the module data from the global table
local function GetModule( moduleName )
	if !NARWHAL.__Modules[moduleName] then
		return false
	end
	return NARWHAL.__Modules[moduleName]
end

// Global function to include a child module for an optional given parent
function IncludeModule( Module )
	local t = GetModule( Module ) -- Gets the module's table
	if !t then
		error( "Inclusion of Module '"..Module.."' Failed: Not registered!\n", 2 )
	end
	return table.Copy( t ) -- Return a copy of the table.
end

// Resets the Module table
// Here we define a set of members and functions that are available in all modules.
local function ResetModuleTable()
	
	MODULE = {}
	
	MODULE.Name = nil
	MODULE.Title = ""
	MODULE.Author = ""
	MODULE.Contact = ""
	MODULE.Purpose = ""
	
	// Includes a module inside a module. Returns the child module.
	function MODULE.Require( moduleName )
		local b, e = pcall( IncludeModule( moduleName ) )
		if !b then
			error( "MODULE.Require on Module '"..moduleName.."' Failed: Not registered!\n", 2 )
		end
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
			moduleHook.Add( hookName, "MODULES."..self.Name..".HOOK."..uniqueName, function( ... ) return func( self, ... ) end )
		else
			moduleHook.Add( hookName, "MODULES."..self.Name..".HOOK."..uniqueName, function( ... ) return func( ... ) end )
		end
	end
	
	// Gets a module key value, or sets one if it's nil
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
	
	// Sets a module key value
	function MODULE:SetKeyValue( key, value )
		if !self.KeyValues then
			self.KeyValues = {}
		end
		self.KeyValues[key] = value
	end
	
	// Generates autohooks.
	function MODULE:GenerateHooks()
		local hooks = moduleHook.GetTable()
		for k, v in pairs( self ) do
			if type(v) == "function" and hooks[k] then
				moduleHook.Add( k, "MODULES."..self.Name..".HOOK.".."BaseFunction_"..k, function( ... ) return v( self, ... ) end )
			end
		end
	end
	
end

// Registers a specific module file
local function RegisterModule( name, path, state )
	
	if !path:find(".lua") then return end -- Don't try to include the "." or ".." folders. -- path:find(".") and 
	
	if GetModule( name ) then
		ErrorNoHalt( "Registration of Module '"..name.."' Failed: A module by this name already exists (Author "..MODULE.Author..")!\n" )
		return
	end
	
	// Does the actuall including
	local function FinalInclude()
	
		/*local pos = path:find( "/" )
		local lastpos
		repeat
			print(pos)
			lastpos = pos
			pos = path:find( "/", pos )
		until ( !pos )*/
		
		local bLoaded, strError = pcall( CompileString( ModuleFiles[name].Code, path ) )
		
		--print( "PCall Module "..name..":", bLoaded, strError )
		
		if !bLoaded then
			ErrorNoHalt( "Registration of Module '",name,"' Failed: "..strError.."\n" )
			table.insert( FailedModules, path )
			return
		end
		
		if !MODULE then
			ErrorNoHalt( "Registration of Module '",name,"' Failed: MODULE table is nil! Conflicting scripts?\n" )
			table.insert( FailedModules, path )
			return
		end
		
		if !MODULE.Name then
			table.insert( FailedModules, ModuleFiles[name].Path )
			ErrorNoHalt( "Registration of module file '"..ModuleFiles[name].Path.."' Failed: MODULE.Name is invalid! Parsing error?\n" )
			return
		end
		
		NARWHAL.__Modules[name] = MODULE
		
		MsgN( "Successfully registered Module '",name,"'!\n" )
		
	end
	
	if state == "client" then
		if CLIENT then
			FinalInclude()
		end
	elseif state == "server" then
		if SERVER then
			FinalInclude()
		end
	elseif state == "shared" then
		FinalInclude()
	end
	
end

// Reads the module's raw text and gathers information about it before including
local function PreloadModuleData( path, state )
	
	if path:find(".") and !path:find(".lua") then return end -- Don't read the "." or ".." folders
	
	// Read/Gather info
	local function ReadText()
		local RawText = file.Read( "../gamemodes/"..path )
		
		local commentPattern1 = "/%*(.*)%*/"
		local commentPattern2 = "%-%-%[%[(.*)%]%]"
		local commentPattern3 = "%-%-(.*)[\n]-"
		local commentPattern4 = "//(.*)[\n]-"
		
		RawText:gsub( commentPattern1, "" )
		RawText:gsub( commentPattern2, "" )
		RawText:gsub( commentPattern3, "" )
		RawText:gsub( commentPattern4, "" )
		
		local Name
		local namePattern = "MODULE%.Name%s*=%s*[\"']*([%w_]+)[\"']*"
		for modName in RawText:gmatch( namePattern ) do
			Name = modName
		end
		if !Name then -- Either the user did something that failed before adding members, or there was a parsing error.
			ErrorNoHalt( "Registration of module file '"..path.."' Failed: Name is invalid! Parsing error?\n" )
			return
		end
		
		local mIncludes = {}
		local includesPattern = "MODULE%.Require%s*%(%s*%p*([%w_]+)%p*%s*%)"
		for reqModule in RawText:gmatch( includesPattern ) do
			table.insert( mIncludes, reqModule )
		end
		ModuleFiles[Name] = { Path = path, State = state, Dependencies = mIncludes, Code = RawText }
		MsgN( "Loaded Module '"..Name.."'." )
	end

	// Make sure it loads in the correct state
	if state == "server" then
		if SERVER then
			ReadText()
		end
	elseif state == "client" then
		if SERVER then
			AddCSLuaFile( path )
		end
		if CLIENT then
			ReadText()
		end
	elseif state == "shared" then
		if SERVER then
			AddCSLuaFile( path )
		end
		ReadText()
	end
	
end

// Preload Module Data
local function PreLoadGamemodeModules()
	local Folder = string.Replace( GM.Folder, "gamemodes/", "" )
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/modules/*") ) do
		if d:find( ".lua" ) then
			PreloadModuleData( Folder.."/gamemode/modules/"..d, "shared" )
		elseif d == "client" or d == "server" or d == "shared" then
			for e, f in pairs( file.FindInLua( Folder.."/gamemode/modules/"..d.."/*" ) ) do
				PreloadModuleData( Folder.."/gamemode/modules/"..d.."/"..f, d )
			end
		end
	end
end

// Recursive function for including modules in the correct order.
local function LoadDependencyTree( name )
	print("Loading Dependency Tree for "..name)
	if !ModuleFiles[name] then -- This module doesnt exist.
		ErrorNoHalt( "Registration of module '"..name.."' Failed: Module is invalid!\n" )
		return
	end
	for _, inc in pairs( ModuleFiles[name].Dependencies ) do -- Loop through the module's dependencies
		print("\tChecking validity for include "..inc)
		if ModuleFiles[inc] then -- If the include exists
			if table.HasValue( FailedModules, ModuleFiles[inc].Path ) then -- Looks like this module has been deemed as failed. Fail any modules that depended on it.
				ErrorNoHalt( "Registration of Module '"..name.."' Failed: Module is dependent on failed module '"..inc.."'!\n" )
				return
			elseif !GetModule( inc ) then -- If the include is registered
				print("\t\tInclude "..inc.." has not been loaded yet...")
				LoadDependencyTree( inc ) -- Perform these actions on the module's dependencies
			end
		else -- Our dependency appears to be invalid. Fail the module.
			ErrorNoHalt( "Registration of Module '"..name.."' Failed: Module is dependent on invalid module '"..inc.."'!\n" )
			return
		end
	end
	ResetModuleTable() -- Reset the Module table
	RegisterModule( name, ModuleFiles[name].Path, ModuleFiles[name].State ) -- Include the module
	table.insert( IncludedModules, name ) -- This module has been successfully included.
end

MsgN("\nLoading Narwhal Modules...")

PreLoadGamemodeModules() -- Preload modules

--PrintTable(ModuleFiles)

MsgN("\nRegistering Narwhal Modules...")

hook = nil -- We don't want your nasty hooks

// Loop through the module data and include their dependencies first
for k, v in pairs( ModuleFiles ) do
	if !table.HasValue( IncludedModules, k ) and !table.HasValue( FailedModules, v.Path ) then
		LoadDependencyTree( k )
	end
end

hook = moduleHook -- Okay you can come out now. :)

MODULE = nil -- Remove the MODULE table.

MsgN("\nInitializing Narwhal Modules...")

// Run all module Initialize functions if they have one.
for k, v in pairs( NARWHAL.__Modules ) do
	if v.Initialize then
		v:Initialize()
		MsgN("Module '"..v.Name.."' Successfully Initialized!")
	end
	v:GenerateHooks()
end

MsgN("\nInitializing Narwhal Loaded, Registered, and Initialized!")




--[[
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
]]--
/*local regPattern = "NARWHAL%.RegisterModule%s*%("..SpaceCharSpace.."MODULE"..SpaceCharSpace.."%)"
if !RawText:find( regPattern ) then
	ErrorNoHalt( "Registration of Module '"..Name.."' Failed: NARWHAL.RegisterModule is missing!\n" )
	return
end*/
/*local function RegisterModule( MODULE )
	
	local name = MODULE.Name
	local path, state = ModuleFiles[name].Path, ModuleFiles[name].State
	
	local function FinalInclude()
		
		local b, e = pcall( function() CompileString( ModuleFiles[name].Code, ModuleFiles[name].Path ) end ) --RunStringEx( ModuleFiles[name].Code, ModuleFiles[name].Path )
		
		print( "CompileString:", b, e)
		--print( MODULE.Name, MODULE.__CompletedInclude )
		
		if !MODULE then return end
		if GetModule( name ) then
			return
		end
		NARWHAL.__Modules[name] = MODULE
		MsgN("Successfully registered Module '",name,"'!\n")
	end
	
	if state == "client" then
		if CLIENT then
			FinalInclude()
		end
	elseif state == "server" then
		if SERVER then
			FinalInclude()
		end
	elseif state == "shared" then
		FinalInclude()
	end
	
end*/

--function NARWHAL.RegisterModule( MODULE )
	--RegisterModule( MODULE )
	--MODULE.__CompletedInclude = true
	--if ModuleFiles[MODULE.Name] then
		--LoadDependencyTree( MODULE.Name )
	--end
--end
