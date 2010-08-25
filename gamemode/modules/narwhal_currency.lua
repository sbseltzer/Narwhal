/*-----------------------------------------------------------------------------
  Auth: Grea$eMonkey
  Name: Currency Module
  Desc: Simple currency system.
-----------------------------------------------------------------------------*/

MODULE.Name = "currency" -- The reference name
MODULE.Title = "Narwhal Currency" -- The display name
MODULE.Author = "Grea$eMonkey" -- The author
MODULE.Contact = "ssjgamemaker@charter.net" -- The author's contact
MODULE.Purpose = "Simple currency system." -- The purpose

local database = MODULE.Require( "database" )

local PLAYER = FindMetaTable( "Player" )
if !PLAYER then return end

// Called one time after the module has loaded.
function MODULE:Initialize()
	self:CreateCurrency( "narwhal", "Narwhal_SetCurrency", "Narwhal_GetCurrency", "Narwhal_AddCurrency", "Narwhal_TakeCurrency", "Narwhal_GiveCurrency" )
end

function MODULE:CreateCurrency( name, set, get, add, take, give )
	
	local networkname = name.."_currency"
	
	if get then
		function PLAYER[get]( self )
			return self:FetchNWFloat( networkname, 0 )
		end
	end
	
	if CLIENT then return end -- We don't want the client to be able to change money stuff.
	
	if set then
		function PLAYER[set]( self, amount )
			self:SendNWFloat( networkname, amount )
		end
	end
	if add then
		function PLAYER[add]( self, amount )
			self:SendNWFloat( networkname, self:FetchNWFloat( networkname, 0 ) + amount )
		end
	end
	if take then
		function PLAYER[take]( self, amount )
			self:SendNWFloat( networkname, self:FetchNWFloat( networkname, 0 ) - amount )
		end
	end
	if give then
		function PLAYER[give]( self, ply, amount )
			self:SendNWFloat( networkname, self:FetchNWFloat( networkname, 0 ) - amount )
			ply:SendNWFloat( networkname, self:FetchNWFloat( networkname, 0 ) + amount )
		end
	end
	
end













