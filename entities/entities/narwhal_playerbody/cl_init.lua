include('shared.lua')

ENT.RenderGroup = RENDERGROUP_BOTH

local PLAYER --[[, bIndex, bIndex2 , matrix, matrix2
local BONES = {
	"ValveBiped.Bip01_Head1",
	"ValveBiped.Bip01_Head2",
	"ValveBiped.Anim_Attachment_LH",
	"ValveBiped.Anim_Attachment_RH",
	"ValveBiped.Bip01_Spine",
	"ValveBiped.Bip01_L_Hand",
	"ValveBiped.Bip01_R_Hand",
	"ValveBiped.Bip01_L_Forearm",
	"ValveBiped.Bip01_R_Forearm",
	"ValveBiped.Bip01_L_Foot",
	"ValveBiped.Bip01_R_Foot",
	"ValveBiped.Bip01_L_Thigh",
	"ValveBiped.Bip01_R_Thigh",
	"ValveBiped.Bip01_L_Calf",
	"ValveBiped.Bip01_R_Calf",
	"ValveBiped.Bip01_L_Shoulder",
	"ValveBiped.Bip01_R_Shoulder",
	"ValveBiped.Bip01_L_Elbow",
	"ValveBiped.Bip01_R_Elbow"
}]]
function ENT:Draw()
	
	PLAYER = self.Entity:GetParent()
	
	if !PLAYER then return end
	
	PLAYER:DestroyShadow()
	/*
	if PLAYER:GetBoneMatrix( 1 ) then
		for k, v in pairs( BONES ) do
			bIndex, bIndex2 = PLAYER:LookupBone( v ), self.Entity:LookupBone( v )
			if bIndex and bIndex2 then
				matrix = PLAYER:GetBoneMatrix( bIndex )
				if matrix then
					matrix2 = self.Entity:SetBoneMatrix( bIndex2, matrix )
				end
			end
		end
	end*/
	self.Entity:DrawShadow( true )
	
	--if IsValid( PLAYER:GetActiveWeapon() ) then
	--	PLAYER:GetActiveWeapon():DrawShadow( true )
	--end
	
	if LocalPlayer() == PLAYER and GetViewEntity() == PLAYER and !gamemode.Call("ShouldDrawLocalPlayer") then
		return
	end
	
	self.Entity:RemoveEffects( EF_ITEM_BLINK )
	self.Entity:DrawModel()
	
	--PLAYER:InvalidateBoneCache()
	--self.Entity:InvalidateBoneCache()
	
end

