
/*---------------------------------------------------------

	Developer's Notes:

---------------------------------------------------------*/

// This is experimental.
NARWHAL_DERIVATIVE = NARWHAL_DERIVATIVE or "base"

// Include shared files
include( 'includes_shd.lua' )

DeriveGamemode( NARWHAL_DERIVATIVE )

GM.Name 		= "Narwhal Base"
GM.Author 		= "Team GModCentral"
GM.Email 		= "team@gmodcentral.com"
GM.Website 		= "www.gmodcentral.com"
GM.TeamBased 	= true
GM.NarwhalTeams	= {}

/*---------------------------------------------------------
  Teams are configured in a special way.
  'Global' is the string name of the global var preceeded by "TEAM_". The 'teamNumber' index is assigned to it.
  'Name' is the display name for the team.
  'Color' is the team color.
  'SpawnPoints' is a table list of spawn points (or just a string for one spawn point).
---------------------------------------------------------*/

function NARWHAL.AddTeam( iTeamNum, strGlobal, strName, tblColor, tblSpawnPoints )
	local GM = GM or GAMEMODE
	GM.NarwhalTeams[iTeamNum] = { Global = strGlobal, Name = strName, Color = tblColor, SpawnPoints = tblSpawnPoints }
end
function NARWHAL.EditTeam( iTeamNum, strGlobal, strName, tblColor, tblSpawnPoints )
	local GM = GM or GAMEMODE
	GM.NarwhalTeams[iTeamNum] = { Global = strGlobal, Name = strName, Color = tblColor, SpawnPoints = tblSpawnPoints }
	GM:CreateTeams()
end

// Fill this in to add your own network structures.
function GM:LoadNetworkConfigurations()
	-- Refer to network/network_shd.lua
end

// Called when deciding which theme to use
function GM:ForceTheme()
	return "Default"
end

--NARWHAL.AddTeam( 1, "ONE", "Team 1 Name", Color(100,200,100), { "info_player_start" } )
--NARWHAL.AddTeam( 2, "TWO", "Team 2 Name", Color(200,100,200), { "info_player_start" } )

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
	
	if !GAMEMODE.Teams or GAMEMODE.Teams[1] or #GAMEMODE.Teams < 1 then return end
	for k, v in pairs( GAMEMODE.Teams ) do
		_G[ "TEAM_" .. string.upper( v.Global ) ] = k
		team.SetUp( k, v.Name, v.Color )
		team.SetSpawnPoint( k, v.SpawnPoints ) // <-- This would be info_terrorist or some entity that is in your map
	end
	--team.CreateTeam( index, name, color, joinable, spawns )
	team.SetSpawnPoint( TEAM_SPECTATOR, "worldspawn" ) 

end
