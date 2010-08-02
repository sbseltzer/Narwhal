

/*---------------------------------------------------------
   Name: gamemode:OnPlayerChat()
		Process the player's chat.. return true for no default
---------------------------------------------------------*/
function GM:OnPlayerChat( player, strText, bTeamOnly, bPlayerIsDead )
	
	//
	// I've made this all look more complicated than it is. Here's the easy version
	//
	// chat.AddText( player, Color( 255, 255, 255 ), ": ", strText )
	//
	
	local tab = {}
	
	if ( bPlayerIsDead ) then
		table.insert( tab, Color( 255, 30, 40 ) )
		table.insert( tab, "*DEAD* " )
	end
	
	if ( bTeamOnly ) then
		table.insert( tab, Color( 30, 160, 40 ) )
		table.insert( tab, "(TEAM) " )
	end
	
	if ( IsValid( player ) ) then
		table.insert( tab, player )
	else
		table.insert( tab, "Console" )
	end
	
	table.insert( tab, Color( 255, 255, 255 ) )
	table.insert( tab, ": "..strText )
	
	chat.AddText( unpack(tab) )

	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:PlayerNoClip( player, bool )
   Desc: Player pressed the noclip key, return true if
		  the player is allowed to noclip, false to block
---------------------------------------------------------*/
function GM:PlayerNoClip( pl, on )
	
	return GAMEMODE.Config.PlayerCanNoClip
	
end

