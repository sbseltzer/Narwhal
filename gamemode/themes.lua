/*---------------------------------------------------------

	Developer's Notes:
	
	Narwhal Themes are basically like Derma Skins, but
	applied to the Gamemode as a whole.
	They're loaded pretty much the same way as modules.
	
---------------------------------------------------------*/


NARWHAL.__ThemeList = {}
local Loaded, NotLoaded, ThemeFolders
local themeHook = hook

// Gets the theme data
function NARWHAL.GetTheme( themeName )
	if !NARWHAL.__ThemeList[themeName] then
		return
	end
	return NARWHAL.__ThemeList[themeName]
end

// Returns the themes table
function NARWHAL.GetThemes()
	return NARWHAL.__ThemeList
end

// Returns the name of the current gamemode theme
function NARWHAL:CurrentTheme()
	return NARWHAL.__CurrentTheme
end

// Sets the gamemode theme
function NARWHAL:SetTheme( themeName )
	if !themeName then return end
	local currentTheme, newTheme = NARWHAL.GetTheme( NARWHAL.__CurrentTheme ), NARWHAL.GetTheme( themeName )
	if !newTheme then return end
	if currentTheme then
		if !gamemode.Call( "ThemeChanged", NARWHAL.__CurrentTheme, themeName ) then
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

// Resets the Theme table
// Here we define a set of members and functions that are available in all themes.
local function CreateThemeTable( name )
	
	THEME = {}
	THEME.Config = {}
	THEME.__ThemeHooks = {}
	THEME.__HookName = name
	THEME.__Functions = {}
	THEME.__Protected = {}
	
	THEME.Name = ""
	THEME.Author = ""
	THEME.Contact = ""
	THEME.Description = ""
	THEME.Protect = true
	
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
			themeHook.Add( hookName, "NARWHAL.__ThemeList."..self.Name..".HOOK."..uniqueName, function( ... ) return func( self, ... ) end )
		else
			themeHook.Add( hookName, "NARWHAL.__ThemeList."..self.Name..".HOOK."..uniqueName, function( ... ) return func( ... ) end )
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

local function SearchThemesFolder( Folder )
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/themes/*" ) ) do
		if !d:find( "%." ) then
			table.insert( ThemeFolders, d )
		end
	end
end

local function HandleUnhandled()

	for k, v in pairs( NotLoaded ) do
		print( "Theme: " .. v.Name .. " was not loaded because not all bases could be found!\n" )
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
		NARWHAL.__ThemeList[v.Name] = v
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
		if !THEME.BaseClass then
			table.insert( NotLoaded, THEME )
			return
		end
	end
	
	table.insert( Loaded, THEME )
	
end

local function LoadThemes( PathList ) -- PathList is a list of theme paths

	local GM = GM or GAMEMODE
	for k, v in pairs( PathList ) do
	
		THEME = CreateThemeTable( v )
		--if file.Exists( "../gamemodes/"..Folder.."/shared.lua" ) then
			include( GM.Folder:sub(11).."/gamemode/themes/"..v.."/shared.lua" )
		--end
		if SERVER then
			--if file.Exists( "../gamemodes/"..Folder.."/init.lua" ) then
				include( GM.Folder:sub(11).."/gamemode/themes/"..v.."/init.lua" )
			--end
		else
			--if file.Exists( "../gamemodes/"..Folder.."/cl_init.lua" ) then
				include( GM.Folder:sub(11).."/gamemode/themes/"..v.."/cl_init.lua" )
			--end
		end
		if !THEME then
			ErrorNoHalt( "\nNarwhal Theme Error in "..v..": The 'THEME' table is nil! Are there errors in the file?\n" )
		/*elseif !THEME.Name then
			ErrorNoHalt( "Narwhal Theme Error: "..v..": The 'THEME.Name' member is nil! Are there errors in the file?\n" )
		elseif THEME.Name:len() == 0 then
			ErrorNoHalt( "Narwhal Theme Error: "..v..": The 'THEME.Name' member is an empty string! The theme name must be more than 0 characters!\n" )
		elseif THEME.Name:find( "[^%w_]" ) then
			ErrorNoHalt( "Narwhal Theme Error: "..v..": The 'THEME.Name' member contains unsafe characters! The theme name may only contain alphanumeric characters and underscores!\n" )
		elseif table.HasValue( Loaded, THEME ) or NARWHAL.__ModuleList[THEME.Name] then
			ErrorNoHalt( "Narwhal Theme Error: "..v..": Another theme named "..THEME.Name.." has already been loaded! Copy-paste mistake?\n" )*/
		else
			Msg("Handling Bases for Theme "..v.."\n")
			HandleTheme( THEME )
		end
		
	end
	
	HandleUnhandled()
	
end

// Set the theme on Initialize
hook.Add( "Initialize", "NARWHAL.Initialize.SetDefaultTheme", function()
	if NARWHAL.Config.UseThemes == false then --[[print("Narwhal Themes are disabled for "..GAMEMODE.Name..".")]] return end
	local force = gamemode.Call( "ForceTheme" )
	if NARWHAL:GetTheme( force ) == nil then return end
	NARWHAL:SetTheme( force )
	print("Forcing Narwhal Theme to "..force..".") 
end )

function IncludeNarwhalThemes( name, reload )

	local function InitWrapper()
		
		if !NARWHAL.Config.UseThemes then Msg("Narwhal Themes are disabled for "..(name or "nil")..".") return end
		
		Msg( "Loading Themes for "..(name or "nil")..":" )
		
		hook = nil
		if reload then
			NARWHAL.__ThemeList = {}
		end
		Loaded = {}
		NotLoaded = {}
		ThemeFolders = {}
		
		local function findBases( t, der )
			if der then -- This is our derived gamemode, so we will want to add its themes too.
				SearchThemesFolder( t.Folder:sub(11) ) -- Add themes from the derivatives's folder.
			end
			if t.BaseClass and t.Folder:sub(11) != "narwhal" then -- If our base isn't narwhal yet, then we need to search deeper.
				SearchThemesFolder( t.BaseClass.Folder:sub(11) ) -- Add themes from the base's folder.
				findBases( t.BaseClass, false ) -- Seach our base's base for themes.
			end
		end
		
		findBases( GM or GAMEMODE or gmod.GetGamemode(), true )
		
		if SERVER then
			for k, v in pairs( ThemeFolders ) do
				local GM = GM or GAMEMODE
				local Folder = GM.Folder:sub(11).."/gamemode/themes/"..v
				--if file.Exists( "../gamemodes/"..Folder.."/shared.lua" ) then
					AddCSLuaFile( Folder.."/shared.lua" )
				--end
				--if file.Exists( "../gamemodes/"..Folder.."/cl_init.lua" ) then
					AddCSLuaFile( Folder.."/cl_init.lua" )
				--end
			end
		end
		
		LoadThemes( ThemeFolders )

		for k, v in pairs( NARWHAL.__ThemeList ) do
			
			if v.Init then
				v:Init()
			end
			if v.AutoHook then
				v:__GenerateHooks()
			end
			v:__GenerateFunctionCalls()
			
		end
		
		THEME = nil
		Loaded = nil
		NotLoaded = nil
		ThemeFolders = nil
		hook = themeHook
		
	end
	
	InitWrapper()
	
end

