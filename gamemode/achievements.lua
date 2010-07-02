
/*---------------------------------------------------------

	Developer's Notes: This file handles achievements.

---------------------------------------------------------*/

GM.Achievements = {} -- Contains gamemode achievements. We'll probably want to make achievements global, so have them in a database or something.

// Function to add achievements. The detect arg is optional. It's only for when you want to use Think for it. Otherwise, you'd give the achievement manually.
function GM:AddAchievement( uniquename, name, desc, icon, detect )
	GAMEMODE.Achievements[uniquename] = {
		Name = name,
		Description = desc,
		Icon = icon,
		Func = function( ply )
			if ply:HasAchievement( uniquename ) then return false end
			return detect( ply )
		end
	}
end

// Example achievement.
GAMEMODE:AddAchievement( "IsAdmin", "The Adminator", "Get switched to the admin usergroup on the server.", "achievements/isadmin", function( ply ) if ply:IsAdmin() then return true end end )

// Loads achievements.
function GM:LoadAchievements()
	
	if !GAMEMODE.Config["UseAchievements"] then return end
	
	local new
	
	for k, v in pairs( GAMEMODE.Achievements ) do
		
		if v.Func then
			
			new = function( ply )
				if v.Func( ply ) then
					ply:GiveAchievement( k )
				end
			end
			
			local function AchievementThink()
				for _, ply in pairs( player.GetAll() ) do
					new( ply )
				end
			end
			
			hook.Add( "Think", "NARWHAL_ACHIEVEMENTS_THINK_"..string.upper( k ), AchievementThink )
			
		end
		
	end
	
end

// Here are a few player methods for achievement related stuff.

local PLAYER = FindMetaTable( "Player" )

function PLAYER:HasAchievement( strAcievement )
	
	-- Check database
	
end
function PLAYER:GiveAchievement( strAcievement )
	
	if self:HasAchievement( strAcievement ) then return end
	
	-- Save to database
	-- Send usermessage to display something clientside
	
end













