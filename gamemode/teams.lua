
/*---------------------------------------------------------

	Developer's Notes:
	
	We want everything we can do with normal teams plus:
		Ability to change their TeamInfo.
		Ability to remove them.
		Capability to add/remove sub-teams (and sub-teams of sub-teams) on the go.
		Capability to add/remove classes on the go.
		
	Narwhals are like fucking sea-unicorns.

---------------------------------------------------------*/




local TEAMS = {}

local function GetGlobalName( name )
	return string.lower( string.upper( string.Trim( string.sub( "team", name ) ) ) )
end

function AddTeam( name, color, spawns )
	
	_G["TEAM_"..GetGlobalName( name )] = #TEAMS+1
	TEAMS[#TEAMS+1] = { Name = name, Color = color, Spawns = spawns }
	
end

function RemoveTeam( name )
	
	for k, v in pairs( TEAMS ) do
		if v.Name == name then
			_G["TEAM_"..GetGlobalName( name )] = -1
			TEAMS[k] = nil
		end
	end
	
end

---- Player ----

local META = FindMetaTable( "Player" )

function META:SetTeam( name )
	self.m_sTeam = _G["TEAM_"..GetGlobalName( name )]
end
function META:Team()
	return self.m_sTeam or 0
end

local team = team
function team.GetColor( ref )
	
	if type( ref ) == "string" then
		
		return TEAMS[_G["TEAM_"..GetGlobalName( name )]]
		
	end
	
	return team.GetColor( ref )
	
end