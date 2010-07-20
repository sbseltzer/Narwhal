
/*---------------------------------------------------------

	Developer's Notes:
	
	Keep your including to init.lua, cl_init.lua, and
	shared.lua. Try not to do much more editing than
	include and AddCSLuaFile in these files unless
	absolutely neccessary.

---------------------------------------------------------*/

include( 'player_shd.lua' )
include( 'networking/network_shd.lua' )
include( 'animations.lua' )

DeriveGamemode( "base" )

GM.Name 		= "Narwhal Base"
GM.Author 		= "Team GModCentral"
GM.Email 		= "team@gmodcentral.com"
GM.Website 		= "www.gmodcentral.com"
GM.TeamBased 	= true
GM.Teams		= {}

/*---------------------------------------------------------
  Teams are configured in a special way.
  'Global' is the string name of the global var preceeded by "TEAM_". The 'teamNumber' index is assigned to it.
  'Name' is the display name for the team.
  'Color' is the team color.
  'SpawnPoints' is a table list of spawn points (or just a string for one spawn point).
---------------------------------------------------------*/
GM.Teams[1] = { Global = "ONE", Name = "Team 1 Name", Color = Color(100,200,100), SpawnPoints = { "info_player_start" } }
GM.Teams[2] = { Global = "TWO", Name = "Team 2 Name", Color = Color(200,100,200), SpawnPoints = { "info_player_start" } }

/*---------------------------------------------------------
   Name: gamemode:PlayerConnect( )
   Desc: Player has connects to the server (hasn't spawned)
---------------------------------------------------------*/
function GM:PlayerConnect( name, address )
end

/*---------------------------------------------------------
   Name: gamemode:PlayerAuthed( )
   Desc: Player's STEAMID has been authed
---------------------------------------------------------*/
function GM:PlayerAuthed( ply, SteamID, UniqueID )
end

/*---------------------------------------------------------
   Name: gamemode:SetupMove( player, movedata )
   Desc: Allows us to change stuff before the engine 
		  processes the movements
---------------------------------------------------------*/
function GM:SetupMove( ply, move )
end

/*---------------------------------------------------------
   Name: gamemode:FinishMove( player, movedata )
---------------------------------------------------------*/
function GM:FinishMove( ply, move )
end

/*---------------------------------------------------------
   Name: gamemode:Move
   This basically overrides the NOCLIP, PLAYERMOVE movement stuff.
   It's what actually performs the move. 
   Return true to not perform any default movement actions. (completely override)
---------------------------------------------------------*/
function GM:Move( ply, move )
end

/*---------------------------------------------------------
   Name: EntityRemoved
   Desc: Called right before an entity is removed. Note that this
   isn't going to be totally reliable on the client since the client
   only knows about entities that it has had in its PVS.
---------------------------------------------------------*/
function GM:EntityRemoved( ent )
	//GAMEMODE:RemoveEntityIndex( ent ) -- Remove all the NWVars from the cache for this entity
end

/*---------------------------------------------------------
   Name: Tick
   Desc: Like Think except called every tick on both client and server
---------------------------------------------------------*/
function GM:Tick()
end

/*---------------------------------------------------------
   Name: OnEntityCreated
   Desc: Called right after the Entity has been made visible to Lua
---------------------------------------------------------*/
function GM:OnEntityCreated( Ent )
end

/*---------------------------------------------------------
   Name: gamemode:CreateTeams()
   Desc: Note - HAS to be shared.
---------------------------------------------------------*/
function GM:CreateTeams()

	// Don't do this if not teambased. But if it is teambased we
	// create a few teams here as an example. If you're making a teambased
	// gamemode you should override this function in your gamemode
	if ( !GAMEMODE.TeamBased ) then return end
	
	if #GAMEMODE.Teams < 1 then return end
	for k, v in pairs( GAMEMODE.Teams ) do
	
		_G[ "TEAM_" .. string.upper( v.Global ) ] = k
		team.SetUp( k, v.Name, v.Color )
		team.SetSpawnPoint( k, v.SpawnPoints ) // <-- This would be info_terrorist or some entity that is in your map
		
	end
	
	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" ) 

end
