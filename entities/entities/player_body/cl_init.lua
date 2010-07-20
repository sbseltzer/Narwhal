include('shared.lua')


function ENT:Draw()
	
	if GetViewEntity() == LocalPlayer() then
		return
	end
	
	self.Entity:RemoveEffects(EF_ITEM_BLINK)
	self.Entity:DrawModel()
	self.Entity:DrawShadow( true )
	
end

