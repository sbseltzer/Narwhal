
/*
	Themes are essentially the same as modules, except they are basically like whole gamemodes.
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

NARWHAL.__Themes = {}
NARWHAL.__CurrentTheme = "Default"

local themeHook = hook

// Gets the current gamemode theme
function GM:GetTheme()
	return NARWHAL.__CurrentTheme
end

// Gets the theme data from the global table
function GM:GetThemeData( themeName )
	if !NARWHAL.__Themes[themeName] then
		return false
	end
	return NARWHAL.__Themes[themeName]
end

// Gets the current gamemode theme
function GM:SetTheme( themeName )
	local current = NARWHAL.__CurrentTheme
	local theme = GAMEMODE:GetThemeData( current )
	for k, v in pairs( theme.Hooks ) do
		hook.Remove( v[1], v[2] )
	end
	theme = GAMEMODE:GetThemeData( themeName )
	for k, v in pairs( theme.Hooks ) do
		hook.Add( unpack( v ) )
	end
	NARWHAL.__CurrentTheme = themeName
end

// Global function to include a child theme for an optional given parent
function GM:ForceTheme( Theme )
	local t = GetTheme( Theme ) -- Gets the theme's table
	if !t then
		error( "Inclusion of Theme '"..Theme.."' Failed: Not registered!\n", 2 )
	end
	return table.Copy( t ) -- Return a copy of the table.
end

// Resets the Theme table
// Here we define a set of members and functions that are available in all themes.
local function ResetThemeTable()
	
	THEME = {}
	THEME.Hooks = {}
	
	THEME.Name = nil
	THEME.Title = ""
	THEME.Author = ""
	THEME.Contact = ""
	THEME.Purpose = ""
	
	// Adds a hook for the specified theme.
	function THEME:Hook( hookName, uniqueName, func )
		local self = self or THEME
		local isMember = false
		for k, v in pairs( self ) do
			if v == func then
				isMember = true
				break
			end
		end
		if isMember then
			table.insert( self.Hooks, { hookName, "THEMES."..self.Name..".HOOK."..uniqueName, function( ... ) return func( self, ... ) end } )
		else
			table.insert( self.Hooks, { hookName, "THEMES."..self.Name..".HOOK."..uniqueName, function( ... ) return func( ... ) end } )
		end
	end
	
	// Generates autohooks.
	function THEME:GenerateHooks()
		local hooks = themeHook.GetTable()
		for k, v in pairs( self ) do
			if type( v ) == "function" and hooks[k] then
				table.insert( self.Hooks, { hookName, "THEMES."..self.Name..".HOOK."..uniqueName, function( ... ) return func( self, ... ) end } )
			end
		end
	end
	
end

// Registers a specific theme file
local function RegisterTheme( name, path, state )
	
	if !path:find(".lua") then return end -- Don't try to include the "." or ".." folders.
	THEME.Name = name
	
	// Does the actuall including
	local function FinalInclude()
		
		local bLoaded, strError = pcall( CompileString( ThemeFiles[name].Code, path ) )
		
		if !bLoaded then
			ErrorNoHalt( "Registration of Theme '",name,"' Failed: "..strError.."\n" )
			table.insert( FailedThemes, path )
			return
		end
		
		if !THEME then
			ErrorNoHalt( "Registration of Theme '",name,"' Failed: THEME table is nil! Conflicting scripts?\n" )
			table.insert( FailedThemes, path )
			return
		end
		
		if !THEME.Name then
			table.insert( FailedThemes, ThemeFiles[name].Path )
			ErrorNoHalt( "Registration of theme file '"..ThemeFiles[name].Path.."' Failed: THEME.Name is invalid! Parsing error?\n" )
			return
		end
		
		NARWHAL.__Themes[name] = THEME
		
		MsgN( "Successfully registered Theme '",name,"'!\n" )
		
	end
	
	if state == "client" then
		if SERVER then
			AddCSLuaFile( path )
		end
		if CLIENT then
			FinalInclude()
		end
	elseif state == "server" then
		if SERVER then
			FinalInclude()
		end
	elseif state == "shared" then
		if SERVER then
			AddCSLuaFile( path )
		end
		FinalInclude()
	end
	
end

// Reads the theme's raw text and gathers information about it before including
local function PreloadThemeData( name, path, state )
	
	if path:find(".") and !path:find(".lua") then return end -- Don't read the "." or ".." folders
	
	// Read/Gather info
	local function ReadText()
		local RawText = file.Read( "../gamemodes/"..path )
		--[[local commentPattern1 = "/%*(.*)%*/"
		local commentPattern2 = "%-%-%[%[(.*)%]%]"
		local commentPattern3 = "%-%-(.*)[\n]-"
		local commentPattern4 = "//(.*)[\n]-"
		RawText:gsub( commentPattern1, "" )
		RawText:gsub( commentPattern2, "" )
		RawText:gsub( commentPattern3, "" )
		RawText:gsub( commentPattern4, "" )]]
		ThemeFiles[name] = { Path = path, State = state, Code = RawText }
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

// Preload Theme Data
local function PreLoadGamemodeThemes()
	local Folder = string.Replace( GM.Folder, "gamemodes/", "" );
	local path, state
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/themes/*") ) do
		path = Folder.."/gamemode/themes/"..d
		if !d:find( ".lua" ) then
			for e, f in pairs( file.FindInLua( Folder.."/gamemode/themes/"..d.."/*" ) ) do
				path = Folder.."/gamemode/themes/"..d.."/"..f
				if f == "init.lua" then
					state = "server"
				elseif f == "cl_init.lua" then
					state = "client"
				elseif f == "shared.lua" then
					state = "shared"
				end
				PreloadThemeData( d, path, state )
			end
		end
	end
end

PreLoadGamemodeThemes() -- Preload themes

hook = nil -- We don't want your nasty hooks

// Loop through the theme data and include their dependencies first
for k, v in pairs( ThemeFiles ) do
	if !ThemeFiles[k] then -- This theme doesnt exist.
		ErrorNoHalt( "Registration of theme '"..name.."' Failed: Theme is invalid!\n" )
		return
	end
	ResetThemeTable() -- Reset the Theme table
	RegisterTheme( k, ThemeFiles[k].Path, ThemeFiles[k].State ) -- Include the theme
end

hook = themeHook -- Okay you can come out now. :)
THEME = nil -- Remove the THEME table.

// Generate our hooks
for k, v in pairs( NARWHAL.__Themes ) do
	v:GenerateHooks()
end







