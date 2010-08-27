
/*---------------------------------------------------------
   Name: gamemode:PlayerDisconnected( )
   Desc: Player has disconnected from the server.
---------------------------------------------------------*/
function GM:PlayerDisconnected( player )
	GAMEMODE:RemoveNetworkedVariables( player )
end

