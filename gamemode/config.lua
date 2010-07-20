
/*---------------------------------------------------------

	Developer's Notes:
	
	Configurations for the entire gamemode.

---------------------------------------------------------*/

GM.Config = {}
GM.Config["UseMySQL"]				= true -- Toggle MySQL Interfaces.
GM.Config["UseLuaAnims"]			= true -- Toggle the Lua based animations. This includes NPC animations merged to the player.
GM.Config["UseMoney"]				= true -- Toggle the money system.
GM.Config["UseAchievements"] 		= true -- Toggle the achievements system.
GM.Config["UseStore"]				= true -- Toggle the gobal store platform.
GM.Config["AllowSprays"]			= true -- Toggle player's ability to spray images.
GM.Config["UseSandboxMenu"]			= true -- Toggle sandbox features.

GM.Config["Commands"]	= { ["sv_alltalk"] = 1 } -- These are called and set with game.ConsoleCommand in gamemode Initialize. This would be good in Grand Colt with controlling player voices (sv_alltalk nullifies the effects of GAMEMODE:PlayerCanHearPlayersVoice)

GM.Config["unstable_settings"]	= { "", "", "" } -- Settings from here that admins will be unable to change while the game is running.

function GM:SetupConfigCommands()
	
	for k, v in pairs( GAMEMODE.Config.Commands ) do
		game.ConsoleCommand( k .. " " .. tostring( v ) )
	end
	
end