
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
	
	return NARWHAL.Config.PlayerCanSuicide
	
end


/*---------------------------------------------------------
   Name: gamemode:PlayerSwitchFlashlight()
		Return true to allow action
---------------------------------------------------------*/
function GM:PlayerSwitchFlashlight( ply, SwitchOn )
	
	return NARWHAL.Config.PlayerCanSwitchFlashlight
	
end

