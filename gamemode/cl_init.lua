
/*---------------------------------------------------------

	Developer's Notes:

---------------------------------------------------------*/


NARWHAL = {}

// Include shared files
include( 'shared.lua' )

// Include client files
include( 'includes_cl.lua' )

/*---------------------------------------------------------
   Name: gamemode:Initialize( )
   Desc: Called immediately after starting the gamemode 
---------------------------------------------------------*/
function GM:Initialize( )

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
   Name: gamemode:PlayerDeath( )
   Desc: Called when a player dies. If the attacker was
		  a player then attacker will become a Player instead
		  of an Entity. 		 
---------------------------------------------------------*/
function GM:PlayerDeath( ply, attacker )
end


/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end

