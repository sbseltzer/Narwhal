
/*-----------------------------------------------------------------------------
  Auth: Grea$eMonkey
  Name: Views
  Desc: Allows people to make view types and set them on a per-player basis.
-----------------------------------------------------------------------------*/

MODULE.Name = "narwhal_view" -- The reference name
MODULE.Title = "Narwhal View" -- The display name
MODULE.Author = "Grea$eMonkey" -- The author
MODULE.Contact = "geekwithalife@gmail.com" -- The author's contact
MODULE.Purpose = "" -- The purpose

local viewpresets = {}


// Called one time after the module has loaded.
function MODULE:Initialize()
	
	local PLAYER = FindMetaTable( "Player" )
	if !PLAYER then return end
	
	function PLAYER:Narwhal_SetViewType( name, body, data )
		if !name then return end
		self:SendNWString( "narwhal_viewtype", name )
		self:SendNWBool( "narwhal_viewtypebody", body )
		if !data then return end
		self:SendNWTable( "narwhal_viewtypedata", data )
	end
	function PLAYER:Narwhal_GetViewType()
		return self:FetchNWString( "narwhal_viewtype", "narwhal_firstperson" ), self:FetchNWBool( "narwhal_viewtypebody", false ), self:FetchNWTable( "narwhal_viewtypedata" )
	end
	function PLAYER:Narwhal_SetViewTypeData( name, key, value )
		return self:FetchNWTable( "narwhal_viewtypedata" )
	end
	function PLAYER:Narwhal_GetViewTypeData( name )
		return self:FetchNWTable( "narwhal_viewtypedata" )
	end
	
	self:CreatePreset( "narwhal_firstperson", function( ply, pos, ang, fov )
		return GAMEMODE:CalcView( ply, pos, ang, fov )
	end )
	
	local view, tr = {}
	self:CreatePreset( "narwhal_thirdperson", function( ply, pos, ang, fov )
		tr = util.QuickTrace( pos, pos + ply:GetAimVector() * -500, {ply} )
		pos = tr.HitPos + tr.Normal * 50
		return GAMEMODE:CalcView( ply, pos, ang, fov )
	end )
	
end

if !CLIENT then return end

function MODULE:CreatePreset( name, func )
	
	viewpresets[name] = func
	
end

function MODULE:ConfiguredCalcView( ply, pos, ang, fov )
	
	
	
end

MODULE:Hook( "CalcView", "DoViews", function( ply, pos, ang, fov )
	
	return viewpresets[ply:FetchNWString( "narwhal_viewtype", "narwhal_firstperson" )]( ply, pos, ang, fov ) or GAMEMODE:CalcView( ply, pos, ang, fov )
	
end )










