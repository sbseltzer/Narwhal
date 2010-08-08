
/*---------------------------------------------------------

	Developer's Notes:
	
	Configurations for the entire gamemode.

---------------------------------------------------------*/

GM.Config = {}

// Feature toggling
GM.Config["UseModules"]					= true	-- Toggle Module Loading.
GM.Config["UseThemes"]					= true	-- Toggle Theme Loading
GM.Config["UseMySQL"]					= true	-- Toggle MySQL Interfaces.
GM.Config["UseAnims"]					= true	-- Toggle the player NPC animations.
GM.Config["UseMoney"]					= true	-- Toggle the money system.
GM.Config["UseStore"]					= true	-- Toggle the gobal store platform.
GM.Config["UseAchievements"] 			= true	-- Toggle the achievements system.
GM.Config["UseSandboxMenu"]				= true	-- Toggle sandbox features? - TODO?

// Player related stuff
GM.Config["PlayerCanNoClip"]			= false	-- Toggle player's ability to use noclip without sv_cheats being 1
GM.Config["PlayerCanSuicide"]			= true	-- Toggle player's ability to commit suicide
GM.Config["PlayerCanSwitchFlashlight"]	= true	-- Toggle player's ability to switch flashlight

// Module related stuff
GM.Config["ModuleListType"]				= "white"	-- Choices are "white" or "black" for whether you want to whitelist of blacklist modules.
GM.Config["ModuleList"]					= {}		-- Here you list all the modules you want or don't want.

// Please choose one or the other.
// If the same module name appears on both, the blacklist will take priority.
// If the same module name doesn't appear on either, the whitelist will take over.
GM.Config["ModuleWhiteList"]			= {}		-- Here you list all the modules you want. Anything that is not on this list WILL NOT be used.
GM.Config["ModuleBlackList"]			= {}		-- Here you list all the modules you don't want. Anything that isn't on this list WILL be used.

GM.Config["Commands"]	= { ["sv_alltalk"] = 1 } -- These are called and set with game.ConsoleCommand in gamemode Initialize. This would be good in Grand Colt with controlling player voices (sv_alltalk nullifies the effects of GAMEMODE:PlayerCanHearPlayersVoice)

GM.Config["unstable_settings"]	= { "UseModules", "UseThemes", "UseMySQL" } -- Settings from here that admins will be unable to change while the game is running.

local configIndex = {}

local function SetupConfigCommands()
	for k, v in pairs( GAMEMODE.Config ) do
		table.insert( configIndex, "_" .. k )
	end
	for k, v in pairs( GAMEMODE.Config.Commands ) do
		game.ConsoleCommand( k .. " " .. tostring( v ) )
	end
end
hook.Add( "Initialize", "NARWHAL_SetupConfigCmds", SetupConfigCommands )

// Console Command for server admins to change Narwhal's Configurations.
// This feels messy to me. Probably needs rewriting.
local function ChangeConfig( ply, cmd, args )
	if !ply:IsAdmin() then
		MsgN( "ONLY ADMINS ARE ALLOWED TO CHANGE CONFIGURATIONS!" )
		return
	end
	local function HasKey( t, key, nonsensitive )
		for k, v in pairs( GAMEMODE.Config ) do
			if nonsensitive and type( k ) == "string" then
				k = k:lower()
			end
			if k == key then
				return true
			end
		end
		return false
	end
	local function HasValue( t, val, nonsensitive )
		for k, v in pairs( GAMEMODE.Config ) do
			if nonsensitive and type( v ) == "string" then
				v = v:lower()
			end
			if v == val then
				return true
			end
		end
		return false
	end
	local function FindMixedCase( t, key )
		for k, v in pairs( GAMEMODE.Config ) do
			if key:lower() == k:lower() then
				return k
			end
		end
		return false
	end
	cmd = cmd:lower()
	if cmd == "unstable_settings" or HasValue( GAMEMODE.Config["unstable_settings"], cmd, true ) then
		MsgN( "THIS SETTING IS UNSTABLE! YOU DO NOT HAVE PERMISSION TO CHANGE IT!" )
		return
	end
	if HasKey( GAMEMODE.Config, cmd, true ) then
		local index = FindMixedCase( GAMEMODE.Config, cmd )
		if index then
			if index:sub( 1, 3 ) == "Use" or index:sub( 1, 6 ) == "Player" then
				GAMEMODE.Config[index] = tobool( args[1] )
			end
		end
	end
end
concommand.Add( "narwhal_cfg", ChangeConfig, configIndex, "This command autocompletes with all available Narwhal configurations." )





















