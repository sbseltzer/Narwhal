
/*---------------------------------------------------------

	Developer's Notes:
	
	I figured it would be easier to collaborate if we put
	all of our includes and AddCSLuaFiles in three
	separate files. That way, no one has to edit init.lua,
	cl_init.lua, or shared.lua.
	
	This is where we include serverside files and add
	clientside files.
	
---------------------------------------------------------*/


include( 'shared.lua' )
include( 'modules.lua' )
include( 'player.lua' )
include( 'config.lua' )
include( 'money.lua' )
include( 'achievements.lua' )
include( 'networking/network.lua' )

AddCSLuaFile( "shared.lua" )
AddCSLuaFile( "modules.lua" )
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "player_shd.lua" )
AddCSLuaFile( "networking/network_cl.lua" )
AddCSLuaFile( "networking/network_shd.lua" )

include( 'sv_testhooks.lua' )
AddCSLuaFile( "cl_testhooks.lua" )

