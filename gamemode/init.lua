
include( 'shared.lua' )
include( 'player.lua' )
include( 'config.lua' )
include( 'money.lua' )
include( 'achievements.lua' )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "player_sdh.lua" )

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )
	GAMEMODE:LoadAchievements()
end


/*---------------------------------------------------------
   Name: gamemode:InitPostEntity( )
   Desc: Called as soon as all map entities have been spawned
---------------------------------------------------------*/
function GM:InitPostEntity( )
	
end


/*---------------------------------------------------------
   Name: gamemode:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function GM:Think( )
	
end


/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
	
end




