
/*---------------------------------------------------------

	Developer's Notes:
	
	Something that makes Narwhal unique is that is can derive
	from anything. To do that, we kind cheat by overriding
	the gamemode.Register function. :V
	This means just about any gamemode can be converted into
	a Narwhal gamemode.
	Think of gamemode deriving as a sandwich with your gamemode
	on top and base gamemode on the bottom. Now Narwhal is
	like a slice of cheese which gets slid somewhere between
	base gamemode and your gamemode. :D
	
	Another thing that makes Narwhal unique is that rather
	than having a huge set of gamemode hooks, it keeps all
	the gamemode data that we'd usually have in the GM table
	in a custom table called NARWHAL.
	Since this table can't exactly derive with the gamemode
	table, we turn it into a metatable that fetches indexes
	from a field of the gamemode table called GM.__Narwhal.
	Every time we make a new index in the NARWHAL table, it
	gets sent to the GM.__Narwhal table.
	
---------------------------------------------------------*/


NARWHAL = NARWHAL or {} -- We use this in place of the GM table wherever we can.
NARWHAL_DERIVATIVE = NARWHAL_DERIVATIVE or "base" -- This needs to be set in the gamemode deriving from Narwhal.
NARWHAL_FOLDER = GM.Folder:sub(11) -- This is used in place of "narwhal" in file path strings.

// Set up basic gamemode values.
GM.Name 		= "Narwhal" -- Gamemode name
GM.Author 		= "Team GModeCentral" -- Author name.
GM.Email 		= "team@gmodcentral.com" -- Author email.
GM.Website 		= "www.gmodcentral.com" -- Website.
GM.TeamBased 	= false -- It's a base gamemode. We don't need teams.
GM.__Narwhal = GM.__Narwhal or {} -- DO NOT TOUCH!

// We're gonna cheat and register the gamemode with your base of choice. ;D
// What this means is you can port just about any gamemode to narwhal by changing just a few lines.
local oldReg = gamemode.Register
function gamemode.Register( t, name, derived )
	if name == NARWHAL_FOLDER and NARWHAL_DERIVATIVE and NARWHAL_DERIVATIVE:lower() != "base" and NARWHAL_DERIVATIVE:lower() != NARWHAL_FOLDER and gamemode.Get( NARWHAL_DERIVATIVE ) != nil then
		oldReg( t, name, NARWHAL_DERIVATIVE )
	else
		oldReg( t, name, derived )
	end
end


// The GM table is only valid while the gamemode is loading. After that the GAMEMODE table must be used.
// We will use this function for getting the valid gamemode table in our metamethods.
local gm_accessor = function()
	-- Since we're using metatable functions to get and set values, we need a function to return a valid table.
	return GM or GAMEMODE or gmod.GetGamemode() -- I'll throw in gmod.GetGamemode() just to be safe. :V
end

// Since NARWHAL is a custom table, it won't quite inherit values when the gamemode derives.
// Metatables allow us to change the behaviors of tables. Let's take advantage of that.
local meta = {}
meta.__index = function( table, key ) -- Whenever NARWHAL can't find something, it will look in the GM.__Narwhal table.
	local t = gm_accessor()
	if !t then
		print( "fail:", t, t.__Narwhal, NARWHAL )
		error( "NARWHAL METATABLE FAILURE: Getting of key '"..key.."' failed!\n", 2 )
	end
	if !t.__Narwhal then
		t.__Narwhal = {}
	end
	return t.__Narwhal[key]
end
meta.__newindex = function( table, key, value ) -- Whenever NARWHAL wants to store something, it will put it in the GM.__Narwhal table.
	local t = gm_accessor()
	if !t then
		print( "fail:", t, t.__Narwhal, NARWHAL )
		error( "NARWHAL METATABLE FAILURE: Setting of key '"..key.."' to value ("..tostring(value)..") failed!\n", 2 )
	end
	if !t.__Narwhal then
		t.__Narwhal = {}
	end
	rawset( table, key, value )
	rawset( t.__Narwhal, key, value )
end
setmetatable( NARWHAL, meta ) -- Since the GM table derives, all of our stored values from NARWHAL will also derive.

// We don't want people to be directly editing the GM.__Narwhal table, so lets make a metatable for it.
local meta2 = {}
meta2.__index = meta2
meta2.__newindex = function( table, key, value )
	if !rawget( NARWHAL, key ) then
		ErrorNoHalt( "You do not have permission to directly edit the GM.__Narwhal table. Values from the GM.__Narwhal table must match those of the NARWHAL table!\n" )
		return
	end
	rawset( table, key, value )
end
setmetatable( GM.__Narwhal, meta2 )

include( 'includes_shd.lua' ) -- Include shared files.

DeriveGamemode( NARWHAL_DERIVATIVE )

// Add modules and themes. You don't need to call these in your gamemodes. It automatically loads modules and themes from any derivatives.
IncludeNarwhalModules() -- Adds modules.
IncludeNarwhalThemes() -- Adds themes.

/*---------------------------------------------------------
   Name: IsNarwhalGamemode
   Desc: I'm not sure if this will even get used, but whatever.
---------------------------------------------------------*/
function GM:IsNarwhalGamemode()
	return true
end

/*---------------------------------------------------------
   Name: LoadNarwhalNetworkConfigurations
   Desc: Called internally to load custom network configurations.
---------------------------------------------------------*/
function GM:LoadNetworkConfigurations()
	-- NARWHAL:AddValidNetworkType( sType, sRef, sStore, funcCheck, funcSend, funcRead )
	-- Refer to network/network_shd.lua
end

/*---------------------------------------------------------
   Name: ForceNarwhalTheme
   Desc: This sets a default theme for the gamemode. Default for no theme.
---------------------------------------------------------*/
function GM:ForceTheme()
	return "Default"
end

/*---------------------------------------------------------
   Name: NarwhalThemeChanged
   Desc: Called when the theme is trying to change.
---------------------------------------------------------*/
function GM:ThemeChanged( oldTheme, newTheme )
	//if oldTheme == "Default" and newTheme == "myAwesomeTheme" then
	//	return false -- We don't want this awesome theme to be set! >:(
	//end
	return true
end


