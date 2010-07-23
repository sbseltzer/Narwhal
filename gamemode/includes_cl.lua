
/*---------------------------------------------------------

	Developer's Notes:
	
	I figured it would be easier to collaborate if we put
	all of our includes and AddCSLuaFiles in three
	separate files. That way, no one has to edit init.lua,
	cl_init.lua, or shared.lua.
	
	This is where we include clientside files.
	
---------------------------------------------------------*/


include( 'shared.lua' )
include( 'modules.lua' )
include( 'networking/network_cl.lua' )
include( 'cl_testhooks.lua' )