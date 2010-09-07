/*---------------------------------------------------------

	Developer's Notes:
	
	Narwhal Themes are basically like Derma Skins, but
	applied to the Gamemode as a whole.
	
---------------------------------------------------------*/

local Themes = {}
local Loaded = {}
local NotLoaded = {}
local ThemeFolders = {}
local themeHook = hook

// Gets the theme data
local function GetTheme( themeName )
	if !Themes[themeName] then
		return
	end
	return Themes[themeName]
end

// Gets the themes table
local function GetThemes()
	return Themes
end

// Gets the current gamemode theme
local function CurrentTheme()
	return NARWHAL.__CurrentTheme
end

// Sets the gamemode theme
local function SetTheme( themeName )
	if !themeName then return end
	local currentTheme, newTheme = GetTheme( CurrentTheme() ), GetTheme( themeName )
	if !newTheme then return end
	if currentTheme then
		if !NARWHAL:ThemeChanged( CurrentTheme(), themeName ) then
			return
		end
		if currentTheme.OnThemeChanged then
			currentTheme:OnThemeChanged( themeName )
		end
		if currentTheme.Hooks then
			currentTheme:UnHookAll()
		end
	end
	if newTheme.Hooks then
		currentTheme:HookAll()
	end
	NARWHAL.__CurrentTheme = themeName
end

NARWHAL.GetTheme = GetTheme
NARWHAL.GetThemes = GetThemes
function NARWHAL:CurrentTheme()
	return CurrentTheme()
end
function NARWHAL:SetTheme( theme )
	SetTheme( theme )
end

// Resets the Theme table
// Here we define a set of members and functions that are available in all themes.
local function CreateThemeTable( name )
	
	THEME = {}
	THEME.__ThemeHooks = {}
	THEME.__HookName = name
	THEME.__Functions = {}
	THEME.__Protected = {}
	
	THEME.Name = ""
	THEME.Author = ""
	THEME.Contact = ""
	THEME.Description = ""
	
	function THEME:__Call( funcName, ... )
		if table.HasValue( self.__Protected, funcName ) then
			ErrorNoHalt( "Attempted to call function "..funcName.." which is on the Protected list. These functions are not supposed to be called via THEME.__Call!\n" )
			return
		end
		local f = self[funcName] and self.__Functions[funcName]
		if f then
			local t = { pcall( self.__Functions[funcName], ... ) }
			if t[1] then
				table.remove( t, 1 )
				return unpack(t)
			else
				ErrorNoHalt( "Narwhal Theme Error in "..self.Name..": "..t[2].."\n" )
			end
		else
			ErrorNoHalt( "Narwhal Theme Error for "..self.Name..": Attempt to call THEME."..funcName.." (function expected, got nil)\n" )
		end
	end
	
	function THEME:__GenerateFunctionCalls()
		print(self.Name)
		PrintTable(self.__Protected)
		for m, f in pairs( self ) do
			if type( f ) == "function" and !table.HasValue( self.__Protected, m ) then
				print( m, f )
				self.__Functions[m] = f
				self[m] = function( ... )
					return self:__Call( m, ... )
				end
			end
		end
	end
	
	// Adds a hook for the specified theme.
	function THEME:Hook( hookName, uniqueName, func, hookForReal )
		local self = self or THEME
		if !self.__ThemeHooks then
			self.__ThemeHooks = {}
		end
		table.insert( self.__ThemeHooks, { hookName, uniqueName, func } )
		if !hookForReal then
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
			themeHook.Add( hookName, "Themes."..self.Name..".HOOK."..uniqueName, function( ... ) return func( self, ... ) end )
		else
			themeHook.Add( hookName, "Themes."..self.Name..".HOOK."..uniqueName, function( ... ) return func( ... ) end )
		end
	end
	
	// Removes a hook for the specified theme.
	function THEME:UnHook( hookName, uniqueName, unhookForReal )
		local self = self or THEME
		if unhookForReal then
			for k, v in pairs( self.__ThemeHooks ) do
				if v[1] == hookName and v[2] == uniqueName then
					themeHook.Remove( v[1], v[2] )
					break
				end
			end
		end
	end
	
	// Generates autohooks.
	function THEME:__GenerateHooks()
		local hooks = themeHook.GetTable()
		for k, v in pairs( self ) do
			if type(v) == "function" and hooks[k] then
				print("Autogenerating function hook on "..k.." for theme "..self.Name)
				self:Hook( k, "BaseFunction_"..k, v, self.AutoHook )
			end
		end
	end
	
	// Adds a hook for the specified theme.
	function THEME:HookAll()
		local self = self or THEME
		if !self.__ThemeHooks then
			return
		end
		for k, v in pairs( self.__ThemeHooks ) do
			self:Hook( unpack( v ), true )
		end
	end
	
	// Removes a hook for the specified theme.
	function THEME:UnHookAll()
		local self = self or THEME
		if !self.__ThemeHooks then
			return
		end
		for k, v in pairs( self.__ThemeHooks ) do
			self:UnHook( v[1], v[2], true )
		end
	end
	
	for k, v in pairs( THEME ) do
		if type( v ) == "function" then
			table.insert( THEME.__Protected, k )
		end
	end
	
	return THEME
	
end

local function SearchThemesFolder()
	local Folder = GM.Folder:sub( 11 )
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/themes/*" ) ) do
		if !d:find( "%." ) then
			table.insert( ThemeFolders, d )
		end
	end
	MsgN("Themes")
	PrintTable( ThemeFolders )
end

local function HandleUnhandled()

	for k, v in pairs( NotLoaded ) do
		Msg( "Theme: " .. v.Name .. " was not loaded because not all dependencies could be found!\n" )
	end
	
	for k, v in pairs( Loaded ) do
		if v.Base and Loaded[v.Base] then
			v = table.Inherit( v, Loaded[v.Base] )
			if v.Base and !v.BaseClass then
				v.BaseClass = Loaded[v.Base]
			end
		else
			local GM = GM or GAMEMODE or gmod.GetGamemode()
			v.BaseClass = GM.BaseClass
		end
		Themes[v.Name] = v
	end
	
	Loaded = nil
	NotLoaded = nil
	
end

local function HandleTheme( THEME )
	
	if !THEME then return end
	
	if THEME.Base then
		for _, theme in pairs( Loaded ) do
			if THEME.Base == theme.Name then
				THEME.BaseClass = theme
			end
		end
	end
	
	table.insert( Loaded, THEME )
	
end

local function LoadThemes( PathList ) -- PathList is a list of theme paths

	local GM = GM or GAMEMODE
	for k, v in pairs( PathList ) do
	
		THEME = CreateThemeTable( v )
		include( GM.Folder:sub(11).."/gamemode/themes/"..v.."/shared.lua" )
		if SERVER then
			include( GM.Folder:sub(11).."/gamemode/themes/"..v.."/init.lua" )
		else
			include( GM.Folder:sub(11).."/gamemode/themes/"..v.."/cl_init.lua" )
		end
		if !THEME then
			ErrorNoHalt( "\nNarwhal Theme Error in "..v..": The 'THEME' table is nil! Are there errors in the file?\n" )
		else
			Msg("\nHandling Base for "..THEME.Name.."\n\n")
			HandleTheme( THEME )
		end
		
	end
	
	HandleUnhandled()
	
end

hook.Add( "Initialize", "NARWHAL_SetDefaultTheme", function()
	if !GetTheme( NARWHAL:ForceTheme() ) then return end
	SetTheme( NARWHAL:ForceTheme() )
end )

hook = nil
SearchThemesFolder()
if SERVER then
	for k, v in pairs( ThemeFolders ) do
		local GM = GM or GAMEMODE
		local Folder = GM.Folder:sub(11).."/gamemode/themes/"..v
		AddCSLuaFile( Folder.."/shared.lua" )
		AddCSLuaFile( Folder.."/cl_init.lua" )
	end
end
LoadThemes( ThemeFolders )
THEME = nil
hook = themeHook

for k, v in pairs( Themes ) do
	
	if v.Init then
		v:Init()
	end
	if v.AutoHook then
		v:__GenerateHooks()
	end
	v:__GenerateFunctionCalls()
	
end


