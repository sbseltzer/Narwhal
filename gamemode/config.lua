
/*---------------------------------------------------------

	Developer's Notes:
	
	Configurations for the entire gamemode.
	This file is still under construction.

---------------------------------------------------------*/

NARWHAL.Config = {}

// Feature toggling
NARWHAL.Config["UseModules"]				= true	-- Toggle Module Loading.
NARWHAL.Config["UseThemes"]					= true	-- Toggle Theme Loading
NARWHAL.Config["UseAnims"]					= true	-- Toggle the player NPC animations.
NARWHAL.Config["UseMySQL"]					= true	-- Toggle MySQL Interfaces.
NARWHAL.Config["UseCurrency"]				= false	-- Toggle the money system.
NARWHAL.Config["UseStore"]					= false	-- Toggle the gobal store platform.
NARWHAL.Config["UseAchievements"] 			= false	-- Toggle the achievements system.

NARWHAL.Config["Commands"]			= { ["sv_alltalk"] = 1 }	-- These are called and set with game.ConsoleCommand in gamemode Initialize.
NARWHAL.Config["Modules"]			= {} 						-- If any of your modules use a custom configuration, you can change it here. MODULE.Config["member"] becomes NARWHAL.Config[moduleName]["member"]
NARWHAL.Config["unstable_settings"]	= {} 						-- Settings from here that admins will be unable to change while the game is running.

// Setup NARWHAL.Config.Commands commands on initialize
hook.Add( "Initialize", "NARWHAL.Initialize.SetupConfigCmds", function()
	if SERVER then
		if NARWHAL.Config.Commands then
			for k, v in pairs( NARWHAL.Config.Commands ) do
				game.ConsoleCommand( k .. " " .. tostring( v ) )
			end
		end
	end
end )






