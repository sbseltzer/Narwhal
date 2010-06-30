GM.Achievements = {}

GM.Achievements["IsAdmin"] = {
	Name = "Be an Admin",
	Description = "Become an admin on this server!",
	CheckFor = {
		Hook = "Think",
		Func = function( ... )
			local has = {}
			for _, pl in pairs( player.GetAll() ) do
				if pl:IsAdmin() then
					table.insert( has, pl )
				end
			end
			for _, pl in pairs( has ) do
				if !pl:HasAchievement("IsAdmin") then
					return pl
				end
			end
		},
	OnSuccess = function( ... )
		local args = { ... }
		local pl = args[1]
		pl:GiveAchievement()
	end,
	Thumbnail = "achievements/isadmin"
}

function GM:LoadAchievements()
	
	if !GAMEMODE.Config["UseAchievements"] then return end
	
	for k, v in pairs( GAMEMODE.Achievements ) do
		
		local func = v.CheckFor.Func
		
		local new = function( ... )
			if func( ... ) then
				v.OnSuccess( func( ... ) )
			end
		end
		
		hook.Add( v.CheckFor.Hook, "NARWHAL_ACHIEVEMENTS_"..string.upper( v.CheckFor.Hook ), new )
		
	end
	
end