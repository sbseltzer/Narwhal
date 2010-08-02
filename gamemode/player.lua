
/*---------------------------------------------------------
   Name: gamemode:PlayerCanPickupWeapon( )
   Desc: Called when a player tries to pickup a weapon.
		  return true to allow the pickup.
---------------------------------------------------------*/
function GM:PlayerCanPickupWeapon( player, entity )

	return true
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerDisconnected( )
   Desc: Player has disconnected from the server.
---------------------------------------------------------*/
function GM:PlayerDisconnected( player )

end


/*---------------------------------------------------------
   Name: gamemode:PlayerDeathSound()
   Desc: Return true to not play the default sounds
---------------------------------------------------------*/
function GM:PlayerDeathSound()
	
	return true
	
end


/*---------------------------------------------------------
   Name: gamemode:CanPlayerSuicide( ply )
   Desc: Player typed KILL in the console. Can they kill themselves?
---------------------------------------------------------*/
function GM:CanPlayerSuicide( ply )
	
	return GAMEMODE.Config.PlayerCanSuicide
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSwitchFlashlight()
		Return true to allow action
---------------------------------------------------------*/
function GM:PlayerSwitchFlashlight( ply, SwitchOn )
	
	return GAMEMODE.Config["PlayerCanSwitchFlashlight"]
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerCanSeePlayersChat()
		Can this player see the other player's chat?
---------------------------------------------------------*/
function GM:PlayerCanSeePlayersChat( strText, bTeamOnly, pListener, pSpeaker )
	
	if ( bTeamOnly ) then
		if ( !IsValid( pSpeaker ) || !IsValid( pListener ) ) then return false end
		if ( pListener:Team() != pSpeaker:Team() ) then return false end
	end
	
	return true
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerCanHearPlayersVoice()
		Can this player see the other player's voice?
---------------------------------------------------------*/
function GM:PlayerCanHearPlayersVoice( pListener, pTalker )
	
	// This is the default action.
	// Note - sv_alltalk 1 makes this hook irrelivant (everyone hears everyone)
	
	return pListener:Team() == pTalker:Team()
	
end
