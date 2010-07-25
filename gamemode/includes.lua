
/*---------------------------------------------------------

	Developer's Notes:
	
	I figured it would be easier to collaborate if we put
	all of our includes and AddCSLuaFiles in three
	separate files. That way, no one has to edit init.lua,
	cl_init.lua, or shared.lua.
	
	This is where we include serverside files and add
	clientside files.
	
---------------------------------------------------------*/


// Include server files
include( 'config.lua' )
include( 'player.lua' )
include( 'money.lua' )
include( 'achievements.lua' )
include( 'networking/network.lua' )

// Add shared files
AddCSLuaFile( "modules.lua" )
AddCSLuaFile( "animations.lua" )
AddCSLuaFile( "player_shd.lua" )

// Add client files
AddCSLuaFile( "networking/network_cl.lua" )
AddCSLuaFile( "networking/network_shd.lua" )

// Temp files for testing
include( 'sv_testhooks.lua' )
AddCSLuaFile( "cl_testhooks.lua" )
