
GM.__Modules = {}

function GM:GetModuleData( moduleName )
	if !GAMEMODE.__Modules[moduleName] then
		ErrorNoHalt( "Module '"..moduleName.."' is not a registered module." )
		return
	end
	return GAMEMODE.__Modules[moduleName]
end

local ModulePath = "modules/"
local ModuleFolders = file.Find( ModulePath )
local ModuleFiles = { Root = file.Find( ModulePath.."*.lua" ) }

for k, v in pairs( ModuleFolders ) do
	if k == "client" or k == "server" or k == "shared" then
		ModuleFiles[k] = file.Find( ModulePath..k.."/*.lua" )
	end
end


// Global function to include a child module for an optional given parent
function IncludeModule( Module, Parent )

	local t = GAMEMODE:GetModuleData( Module ) -- Gets the module's table
	
	if !t then
		error( "The inclusion of Module '"..Module.."' failed! Halting dependency tree." )
	end
	
	return table.Copy( t ) -- Return a copy of the table.
	
end


local function ResetModuleTable()
	
	// Resets the Module table
	MODULE = {}
	MODULE.Object = {}
	
	MODULE.Name = nil
	MODULE.Title = ""
	MODULE.Author = ""
	MODULE.Contact = ""
	MODULE.Purpose = ""
	MODULE.CreateObject = false

	// Adds a hook for the specified module.
	function MODULE.Hook( hookName, uniqueName, func )
		local mFunc = function( ... )
			-- Shouldn't we have some way to disable these hooks?
			return func( ... )
		end
		hook.Add( hookName, "MODULES.HOOK."..uniqueName, mFunc )
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
	
	// Includes a module inside a module. Returns the child module.
	function MODULE.Require( moduleName )
		if !MODULE.Includes then
			MODULE.Includes = {}
		end
		table.insert( MODULE.Includes, moduleName )
	end
	
	// Gets the module data of an included module
	function MODULE:GetInclude( moduleName )
		if !self.Includes then
			ErrorNoHalt( "Module '"..self.Name.."' has no includes.\n" )
			return
		end
		if !table.HasValue( self.Includes, moduleName ) then
			ErrorNoHalt( "Module '"..self.Name.."' does not have the include '"..moduleName.."'.\n" )
			return
		end
		return IncludeModule( moduleName )
	end
	
end

local function RegisterModule( MODULE, path, state )
	
	if MODULE.ObjectName then
		local ModuleObject = {}
		MODULE.Object.__index = ModuleObject
		function MODULE:Constructor()
			local obj = {}
			obj = self:SetupObject( obj )
			setmetatable( obj, self.Object )
			return obj
		end
	end
	
	for k, v in pairs( MODULE ) do
		
		if type(v) == "function" then
			
			if !GAMEMODE:GetModuleData( MODULE.Name ).Enabled then
				MODULE.Cached[k] = v
				MODULE[k] = function()
					return false
				end
			else
				MODULE[k] = MODULE.Cached[k]
			end
			
		end
		
	end
	
	if state == "client" then
		if SERVER then
			AddCSLuaFile( path )
		end
		if CLIENT then
			include( path )
			GAMEMODE.__Modules[MODULE.Name] = MODULE
		end
	elseif state == "server" then
		if SERVER then
			include( path )
			GAMEMODE.__Modules[MODULE.Name] = MODULE
		end
	elseif state == "shared" then
		if SERVER then
			AddCSLuaFile( ModulePath .. mfile )
		end
		include( path )
		GAMEMODE.__Modules[MODULE.Name] = MODULE
	end
	
end

for mdir, mfile in pairs( ModuleFiles ) do

	local path
	
	// Make sure that modules are loaded in the correct lua state.
	if mdir == "Root" then
		path = ModulePath .. mfile
		if mfile:sub( 3 ) == "cl_" then
			RegisterModule( MODULE, path, "client" )
		elseif mfile:sub( 3 ) == "sv_" then
			RegisterModule( MODULE, path, "server" )
		else
			RegisterModule( MODULE, path, "shared" )
		end
	else
		for _, sfile in pairs( mfile ) do
			path = ModulePath .. mdir .. "/" .. sfile .. ".lua"
			if mdir == "client" then
				RegisterModule( MODULE, path, "client" )
			elseif mdir == "server" then
				RegisterModule( MODULE, path, "server" )
			elseif mdir == "shared" then
				RegisterModule( MODULE, path, "shared" )
			end
		end
	end
	
end

MODULE = nil















