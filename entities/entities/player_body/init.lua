
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

function ENT:Initialize()
	self.Entity:AddEffects( EF_BONEMERGE | EF_BONEMERGE_FASTCULL | EF_PARENT_ANIMATES )
	--print( tostring( math.ceil( math.log( 2.71828 ) ) ) .. " " .. tostring( math.floor( math.log10( math.pow( 2, 7 ) ) ) * 8 ^ 2 ) .. " " .. tostring( math.floor( math.log10( math.pow( 2, 7 ) ) ) * ( math.pow( 2, 5 ) * math.pow( 13 + 3, 0.5 ) ) ) * 2 )
	self.Entity:SetRenderMode( RENDERMODE_NORMAL )
end

