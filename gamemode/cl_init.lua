
/*---------------------------------------------------------

	Developer's Notes:
	
	Keep your including to init.lua, cl_init.lua, and
	shared.lua. Try not to do much more editing than
	include and AddCSLuaFile in these files unless
	absolutely neccessary.

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
   Name: gamemode:PlayerBindPress( )
   Desc: A player pressed a bound key - return true to override action		 
---------------------------------------------------------*/
function GM:PlayerBindPress( pl, bind, down )

	// If we're driving, toggle third person view using duck
	if ( down && bind == "+duck" && ValidEntity( pl:GetVehicle() ) ) then
	
		local iVal = gmod_vehicle_viewmode:GetInt()
		if ( iVal == 0 ) then iVal = 1 else iVal = 0 end
		RunConsoleCommand( "gmod_vehicle_viewmode", iVal )
		return true
		
	end

	return false	
	
end

/*---------------------------------------------------------
   Name: gamemode:HUDShouldDraw( name )
   Desc: return true if we should draw the named element
---------------------------------------------------------*/
function GM:HUDShouldDraw( name )

	// Allow the weapon to override this
	local ply = LocalPlayer()
	if (ply && ply:IsValid()) then
	
		local wep = ply:GetActiveWeapon()
		
		if (wep && wep:IsValid() && wep.HUDShouldDraw != nil) then
		
			return wep.HUDShouldDraw( wep, name )
			
		end
		
	end

	return true
	
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaint( )
   Desc: Use this section to paint your HUD
---------------------------------------------------------*/
function GM:HUDPaint()
	GAMEMODE:HUDDrawTargetID()
	GAMEMODE:HUDDrawPickupHistory()
	GAMEMODE:DrawDeathNotice( 0.85, 0.04 )
end

/*---------------------------------------------------------
   Name: gamemode:HUDPaintBackground( )
   Desc: Same as HUDPaint except drawn before
---------------------------------------------------------*/
function GM:HUDPaintBackground()
end

/*---------------------------------------------------------
   Name: gamemode:CreateMove( command )
   Desc: Allows the client to change the move commands 
			before it's send to the server
---------------------------------------------------------*/
function GM:CreateMove( cmd )
end

/*---------------------------------------------------------
   Name: gamemode:ShutDown( )
   Desc: Called when the Lua system is about to shut down
---------------------------------------------------------*/
function GM:ShutDown( )
end


/*---------------------------------------------------------
   Name: gamemode:RenderScreenspaceEffects( )
   Desc: Bloom etc should be drawn here (or using this hook)
---------------------------------------------------------*/
function GM:RenderScreenspaceEffects()
end


/*---------------------------------------------------------
   Name: gamemode:PostProcessPermitted( str )
   Desc: return true/false depending on whether this post process should be allowed
---------------------------------------------------------*/
function GM:PostProcessPermitted( str )
	return true
end


/*---------------------------------------------------------
   Name: gamemode:PostRenderVGUI( )
   Desc: Called after VGUI has been rendered
---------------------------------------------------------*/
function GM:PostRenderVGUI()
end


/*---------------------------------------------------------
   Name: gamemode:RenderScene( )
   Desc: Render the scene
---------------------------------------------------------*/
function GM:RenderScene()
end


/*---------------------------------------------------------
   Name: CalcView
   Allows override of the default view
---------------------------------------------------------*/
function GM:CalcView( ply, origin, angles, fov )
	
	local Vehicle = ply:GetVehicle()
	local wep = ply:GetActiveWeapon()
	
	if ( ValidEntity( Vehicle ) && 
		 gmod_vehicle_viewmode:GetInt() == 1 
		 /*&& ( !ValidEntity(wep) || !wep:IsWeaponVisible() )*/
		) then
		
		return GAMEMODE:CalcVehicleThirdPersonView( Vehicle, ply, origin*1, angles*1, fov )
		
	end

	local ScriptedVehicle = ply:GetScriptedVehicle()
	if ( ValidEntity( ScriptedVehicle ) ) then
	
		// This code fucking sucks.
		local view = ScriptedVehicle.CalcView( ScriptedVehicle:GetTable(), ply, origin, angles, fov )
		if ( view ) then return view end

	end

	local view = {}
	view.origin 	= origin
	view.angles		= angles
	view.fov 		= fov
	
	// Give the active weapon a go at changing the viewmodel position
	
	if ( ValidEntity( wep ) ) then
	
		local func = wep.GetViewModelPosition
		if ( func ) then
			view.vm_origin,  view.vm_angles = func( wep, origin*1, angles*1 ) // Note: *1 to copy the object so the child function can't edit it.
		end
		
		local func = wep.CalcView
		if ( func ) then
			view.origin, view.angles, view.fov = func( wep, ply, origin*1, angles*1, fov ) // Note: *1 to copy the object so the child function can't edit it.
		end
	
	end
	
	return view
	
end


/*---------------------------------------------------------
   Name: gamemode:AdjustMouseSensitivity()
   Desc: Allows you to adjust the mouse sensitivity.
		 The return is a fraction of the normal sensitivity (0.5 would be half as sensitive)
		 Return -1 to not override.
---------------------------------------------------------*/
function GM:AdjustMouseSensitivity( fDefault )

	local ply = LocalPlayer()
	if (!ply || !ply:IsValid()) then return -1 end

	local wep = ply:GetActiveWeapon()
	if ( wep && wep.AdjustMouseSensitivity ) then
		return wep:AdjustMouseSensitivity()
	end

	return -1
	
end


/*---------------------------------------------------------
   Name: gamemode:PostPlayerDraw()
   Desc: The player has just been drawn.
---------------------------------------------------------*/
function GM:PostPlayerDraw( ply )
	
end

/*---------------------------------------------------------
   Name: gamemode:PrePlayerDraw()
   Desc: The player is just about to be drawn.
---------------------------------------------------------*/
function GM:PrePlayerDraw( ply )
	
end


/*---------------------------------------------------------
   Name: gamemode:GetMotionBlurSettings()
   Desc: Allows you to edit the motion blur values
---------------------------------------------------------*/
function GM:GetMotionBlurValues( x, y, fwd, spin )

	// fwd = 0.5 + math.sin( CurTime() * 5 ) * 0.5

	return x, y, fwd, spin
	
end


/*---------------------------------------------------------
   Name: gamemode:InputMouseApply()
   Desc: Allows you to control how moving the mouse affects the view angles
---------------------------------------------------------*/
function GM:InputMouseApply( cmd, x, y, angle )
	
	//angle.roll = angle.roll + 1	
	//cmd:SetViewAngles( Ang )
	//return true
	
end


/*---------------------------------------------------------
   Name: gamemode:PreDrawSkyBox()
   Desc: Called before drawing the skybox. Return true to not draw the skybox.
---------------------------------------------------------*/
function GM:PreDrawSkyBox()
	
	//return true;
	
end

/*---------------------------------------------------------
   Name: gamemode:PostDrawSkyBox()
   Desc: Called after drawing the skybox
---------------------------------------------------------*/
function GM:PostDrawSkyBox()
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PreDrawOpaqueRenderables( bDrawingDepth, bDrawingSkybox )
	
	//	return true;
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PostDrawOpaqueRenderables( bDrawingDepth, bDrawingSkybox )
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PreDrawTranslucentRenderables( bDrawingDepth, bDrawingSkybox )
	
	// return true
	
end

/*---------------------------------------------------------
   Name: gamemode:PreDrawOpaqueRenderables()
   Desc: Called before drawing opaque entities
---------------------------------------------------------*/
function GM:PostDrawTranslucentRenderables( bDrawingDepth, bDrawingSkybox )
	
end

