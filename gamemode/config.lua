
/*---------------------------------------------------------

	Developer's Notes:
	
	Configurations for the entire gamemode.
	This file is still under construction.

---------------------------------------------------------*/

NARWHAL.Config = {}

// Feature toggling
NARWHAL.Config["UseModules"]				= true	-- Toggle Module Loading.
NARWHAL.Config["UseThemes"]					= true	-- Toggle Theme Loading
NARWHAL.Config["UseMySQL"]					= true	-- Toggle MySQL Interfaces.
NARWHAL.Config["UseAnims"]					= true	-- Toggle the player NPC animations.
NARWHAL.Config["UseMoney"]					= true	-- Toggle the money system.
NARWHAL.Config["UseStore"]					= true	-- Toggle the gobal store platform.
NARWHAL.Config["UseAchievements"] 			= true	-- Toggle the achievements system.
NARWHAL.Config["UseSandboxMenu"]			= true	-- Toggle sandbox features? - TODO?

// Module related stuff
NARWHAL.Config["ModuleListType"]			= "white"	-- Choices are "white" or "black" for whether you want to whitelist of blacklist modules.
NARWHAL.Config["ModuleList"]				= {}		-- Here you list all the modules you want or don't want.
NARWHAL.Config["Modules"]					= {}

// Please choose one or the other.
// If the same module name appears on both, the blacklist will take priority.
// If the same module name doesn't appear on either, the whitelist will take over.
NARWHAL.Config["ModuleWhiteList"]			= {}		-- Here you list all the modules you want. Anything that is not on this list WILL NOT be used.
NARWHAL.Config["ModuleBlackList"]			= {}		-- Here you list all the modules you don't want. Anything that isn't on this list WILL be used.

NARWHAL.Config["Commands"]	= { ["sv_alltalk"] = 1 } -- These are called and set with game.ConsoleCommand in gamemode Initialize. This would be good in Grand Colt with controlling player voices (sv_alltalk nullifies the effects of GAMEMODE:PlayerCanHearPlayersVoice)

NARWHAL.Config["unstable_settings"]	= { "UseModules", "UseThemes", "UseMySQL", "Commands" } -- Settings from here that admins will be unable to change while the game is running.

local function SetupConfigCommands()
	if SERVER then
		for k, v in pairs( NARWHAL.Config.Commands ) do
			game.ConsoleCommand( k .. " " .. tostring( v ) )
		end
	end
	for k, v in pairs( NARWHAL.GetModules() ) do
		if v.Config then
			NARWHAL.Config["Modules"][v.Name] = v.Config
		end
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
	if !cmd or cmd == "" then
		PrintTable( NARWHAL.Config )
		return
	end
	local function HasKey( t, key, nonsensitive )
		for k, v in pairs( NARWHAL.Config ) do
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
		for k, v in pairs( NARWHAL.Config ) do
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
		for k, v in pairs( NARWHAL.Config ) do
			if key:lower() == k:lower() then
				return k
			end
		end
		return false
	end
	cmd = cmd:lower()
	if cmd == "unstable_settings" or HasValue( NARWHAL.Config["unstable_settings"], cmd, true ) then
		MsgN( "THIS SETTING IS UNSTABLE! YOU DO NOT HAVE PERMISSION TO CHANGE IT!" )
		return
	end
	if HasKey( NARWHAL.Config, cmd, true ) then
		local index = FindMixedCase( NARWHAL.Config, cmd )
		if index then
			if index:sub( 1, 3 ) == "Use" or index:sub( 1, 6 ) == "Player" then
				NARWHAL.Config[index] = tobool( args[1] )
			end
		end
	end
end
concommand.Add( "narwhal_cfg", ChangeConfig )




















