
/*---------------------------------------------------------

	Developer's Notes:
	
	Keep your including to init.lua, cl_init.lua, and
	shared.lua. Try not to do much more editing than
	include and AddCSLuaFile in these files unless
	absolutely neccessary.
	
---------------------------------------------------------*/


include( 'includes.lua' )
include( 'includes_shd.lua' )

AddCSLuaFile( "includes_cl.lua" )
AddCSLuaFile( "includes_shd.lua" )

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )
	--GAMEMODE:AddAchievements()
	--GAMEMODE:LoadAchievements()
	GAMEMODE:SetupConfigCommands()
	GAMEMODE:LoadNetworkConfigurations_Internal()
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




