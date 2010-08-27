
/*
	UNFINISHED
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

local ThemeFiles = {}
local themeHook = hook

NARWHAL.__Themes = {}
NARWHAL.__CurrentTheme = "Default"

// Gets the current gamemode theme
function GM:GetCurrentTheme()
	return NARWHAL.__CurrentTheme
end

// Gets the theme data from the global table
function GM:GetThemeData( themeName )
	if !NARWHAL.__Themes[themeName] then
		return false
	end
	return NARWHAL.__Themes[themeName]
end

// Sets the gamemode theme
function GM:SetTheme( themeName )
	local oldtheme, newtheme = GAMEMODE:GetThemeData( NARWHAL.__CurrentTheme ), GAMEMODE:GetThemeData( themeName )
	if oldtheme.OnThemeChanged then
		oldtheme:OnThemeChanged( themeName )
	end
	for k, v in pairs( oldtheme.Hooks ) do
		hook.Remove( v[1], v[2] )
	end
	for k, v in pairs( newtheme.Hooks ) do
		hook.Add( unpack( v ) )
	end
	NARWHAL.__CurrentTheme = themeName
	THEME = newtheme
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
	
	THEME.Derive = "" -- I'm thinking of making it so modules can derive from one another.
	
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
		ThemeFiles[name] = { Path = path, State = state, Code = file.Read( "../gamemodes/"..path ) }
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
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/themes/*") ) do
		if !d:find( "." ) then
			for e, f in pairs( file.FindInLua( Folder.."/gamemode/themes/"..d.."/*" ) ) do
				local state
				if f == "init.lua" then
					state = "server"
				elseif f == "cl_init.lua" then
					state = "client"
				elseif f == "shared.lua" then
					state = "shared"
				end
				PreloadThemeData( d, Folder.."/gamemode/themes/"..d.."/"..f, state )
			end
		end
	end
end

MsgN( "Preloading Themes..." )
PreLoadGamemodeThemes() -- Preload themes

hook = nil -- We don't want your nasty hooks

MsgN( "Registering Themes..." )
// Loop through the theme data and include their dependencies first
for k, v in pairs( ThemeFiles ) do
	if !ThemeFiles[k] then -- This theme doesnt exist.
		ErrorNoHalt( "Registration of theme '"..name.."' Failed: Theme is invalid!\n" )
		return
	end
	ResetThemeTable() -- Reset the Theme table
	MsgN( "Registering Theme "..k )
	RegisterTheme( k, ThemeFiles[k].Path, ThemeFiles[k].State ) -- Include the theme
end
MsgN( "Finished Registering Themes..." )

hook = themeHook -- Okay you can come out now. :)
THEME = nil -- Remove the THEME table.

// Generate our hooks
for k, v in pairs( NARWHAL.__Themes ) do
	v:GenerateHooks()
end







