
/*---------------------------------------------------------

	Developer's Notes: This file handles money.

---------------------------------------------------------*/

GM.MoneyName	= "Credits"	-- The alias of money in the gamemode ( Dollars, Gold, Credits, Cash, Clams, etc. )
GM.StartMoney	= 10		-- Starting money for new players.
GM.MinGiven		= 5			-- You're not allowed to give less than this amount.
GM.MaxGiven		= 500		-- You're not allowed to give more than this amount.

local PLAYER = FindMetaTable( "Player" )

function PLAYER:SetMoney( amount )
	
	self.m_nMoney = amount

end

function PLAYER:AddMoney( amount )
	
	self.m_nMoney = self.m_nMoney + amount

end

function PLAYER:GetMoney( )
	
	return self.m_nMoney
	
end

function PLAYER:GiveMoney( ply, amount )
	
	if ply == self then
		ErrorNoHalt( "You cannot give yourself money!\n" )
		return
	end
	
	if self:GetMoney() < amount then
		Msg( "Not enough ", GAMEMODE.MoneyName, "!\n" )
		return
	elseif amount < GAMEMODE.MinGiven then
		Msg( "You need to give at least ", GAMEMODE.MoneyName, "!\n" )
		return
	elseif amount >= GAMEMODE.MaxGiven then
		Msg( "That's too many ", GAMEMODE.MoneyName, "!\n" )
		return
	end
	
	if type( ply ) == "number" then
		self:AddMoney( amount )
		return
	end
	
	self:AddMoney( -amount )
	ply:AddMoney( amount )
	
end






