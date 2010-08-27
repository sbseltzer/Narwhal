/*-----------------------------------------------------------------------------
  Auth: Grea$eMonkey
  Name: Currency Module
  Desc: Simple currency system.
-----------------------------------------------------------------------------*/

MODULE.Name = "narwhal_currency" -- The reference name
MODULE.Title = "Narwhal Currency" -- The display name
MODULE.Author = "Grea$eMonkey" -- The author
MODULE.Contact = "geekwithalife@gmail.com" -- The author's contact
MODULE.Purpose = "Simple currency system." -- The purpose

local PLAYER = FindMetaTable( "Player" )
if !PLAYER then return end

local database
if SERVER then
	database = MODULE.Require( "narwhal_database" )
end

// Called one time after the module has loaded.
function MODULE:Initialize()
	self:CreateCurrency( "narwhal", "Narwhal_SetCurrency", "Narwhal_GetCurrency", "Narwhal_AddCurrency", "Narwhal_TakeCurrency", "Narwhal_GiveCurrency" )
end

function MODULE:CreateCurrency( name, set, get, add, take, give )
	
	if !name then return end
	
	local networkname = name.."_currency"
	
	// Get can be shared. ;)
	if get then
		PLAYER[get] = function( self )
			return self:FetchNWInt( networkname, 0 )
		end
	end
	
	if CLIENT then return end -- We don't want the client to be able to change money stuff.
	
	if set then
		PLAYER[set] = function( self, amount )
			self:SendNWInt( networkname, amount )
		end
	end
	if add then
		PLAYER[add] = function( self, amount )
			self:SendNWInt( networkname, self:FetchNWInt( networkname, 0 ) + amount )
		end
	end
	if take then
		PLAYER[take] = function( self, amount )
			self:SendNWInt( networkname, self:FetchNWInt( networkname, 0 ) - amount )
		end
	end
	if give then
		PLAYER[give] = function( self, ply, amount )
			self:SendNWInt( networkname, self:FetchNWInt( networkname, 0 ) - amount )
			ply:SendNWInt( networkname, self:FetchNWInt( networkname, 0 ) + amount )
		end
	end
	
end













