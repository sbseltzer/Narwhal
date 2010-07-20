--Hey hey hey! It's fucking NPC animations version three! This time with no Rick Dark shit.
--Credits to Azuisleet ( Original hook ), Entoros( Holdtype thing -- Which is no more, since garry added that in :/ ), and well, me, Big Bang/F-Nox ( everything else )

--Weapons that are always aimed
local AlwaysAimed = 
{
	"weapon_physgun",
	"weapon_physcannon",
	"weapon_frag",
	"weapon_slam",
	"weapon_rpg",
	"gmod_tool"
}

--Weapons that are never aimed
local NeverAimed =
{
	"hands"
}

function MakeAim( ply )
	
	if ValidEntity( ply:GetActiveWeapon() ) then
		if !table.HasValue( NeverAimed, ply:GetActiveWeapon():GetClass() ) then
			ply:SetNWBool( "aiming", true )
			if SERVER then
				ply:DrawViewModel( true )
			end
			--ply:GetActiveWeapon():SendWeaponAnim( ACT_VM_DRAW )
			ply:GetActiveWeapon():SetNWBool( "NPCAimed", true );
		else
			MakeUnAim( ply )
		end
	end

end

function MakeUnAim( ply )

	if ValidEntity( ply:GetActiveWeapon() ) then
		if( !ply:GetActiveWeapon():GetDTBool( 1 ) and !table.HasValue( AlwaysAimed, ply:GetActiveWeapon():GetClass()) ) then
			ply:SetNWBool( "aiming", false )
			--ply:GetActiveWeapon():SendWeaponAnim( ACT_VM_HOLSTER )
				if SERVER then
					ply:DrawViewModel( false )
				end
			if( ply:GetActiveWeapon():IsValid() ) then
				ply:GetActiveWeapon():SetNWBool( "NPCAimed", false );
			end
		else
			MakeAim( ply )
		end
	end
	
end

local function HolsterToggle( ply )

	if( not ply:GetActiveWeapon():IsValid() ) then
		return;
	end

	if( !ply:GetNWBool( "aiming", false ) ) then
	
		MakeAim( ply );
		ply:SetNWBool( "forceaim", true )
		
	else
		
		MakeUnAim( ply );
		ply:SetNWBool( "forceaim", false )
		
	end

end
concommand.Add( "rp_toggleholster", HolsterToggle );
concommand.Add( "toggleholster", HolsterToggle );

local function NPCWeaponHook( ply, key )
	if key == IN_ATTACK or key == IN_ATTACK2 then
		MakeAim( ply )
		ply.IsFuckinShooting = true 
		timer.Create( ply:Nick() .. "weaponholster", 4, 1, function()
			if ValidEntity( ply ) and !ply:GetNWBool( "forceaim", false ) then
				if !ply:GetActiveWeapon():SetNWBool( "NPCAimed", false ) and !ply.IsFuckinShooting then
					MakeUnAim( ply )
				end
			end
		end)
	else
		ply.IsFuckinShooting = false
		if( !timer.IsTimer( ply:Nick() .. "weaponholster" ) ) then
			timer.Create( ply:Nick() .. "weaponholster", 4, 1, function()
				if ValidEntity( ply ) and !ply:GetNWBool( "forceaim", false ) then
					if ply:GetActiveWeapon():IsValid() then
						if !ply:GetActiveWeapon():SetNWBool( "NPCAimed", false ) and !ply.IsFuckinShooting then
							MakeUnAim( ply )
						end
					end
				end
			end)
		end
	end
	
	if key == IN_RUN then
		MakeUnAim( ply )
	end
	
	if ValidEntity( ply:GetActiveWeapon() ) and table.HasValue( AlwaysAimed, ply:GetActiveWeapon():GetClass() ) then
		MakeAim( ply )
	end
	
	if ValidEntity( ply:GetActiveWeapon() ) and table.HasValue( NeverAimed, ply:GetActiveWeapon():GetClass() ) then
		MakeUnAim( ply )
	end
	
end
hook.Add( "KeyPress", "NPCWeaponHook", NPCWeaponHook )

local Anims = {}
Anims.Male = {}
Anims.Male[ "models" ] = {
	"models/barney.mdl",
	"models/eli.mdl",
	"models/breen.mdl",
	"models/Gustavio/maleanimtree.mdl",
	"models/Gustavio/combineanimtree.mdl",
	"models/Gustavio/metroanimtree.mdl",
	"models/kleiner.mdl"
}
Anims.Male[ "default" ] = { 
        [ "idle" ] = "ACT_IDLE",
        [ "walk" ] = "ACT_WALK",
        [ "run" ] = "ACT_RUN",
        [ "jump" ] = "ACT_JUMP",
        [ "land" ] = "ACT_LAND",
        [ "fly" ] = "ACT_GLIDE",
        [ "sit" ] = "ACT_BUSY_SIT_CHAIR",
        [ "sitground" ] = "ACT_BUSY_SIT_GROUND",
        [ "flinch" ] = {
                ["explosion"] = "ACT_GESTURE_FLINCH_BLAST"
                },
		[ "crouch" ] = {
				[ "idle" ] = "ACT_COVER_LOW",
				[ "walk" ] = "ACT_WALK_CROUCH",
				[ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
				[ "aimwalk" ] = "ACT_WALK_CROUCH_AIM_RIFLE"
		},
		[ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_AIM_RIFLE_STIMULATED",
                [ "walk" ] = "ACT_WALK_AIM_RIFLE_STIMULATED",
                [ "run" ] = "ACT_RUN_AIM_RIFLE_STIMULATED"
        }
}
Anims.Male[ "pistol" ] = {
        [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE_PISTOL",
        [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_PISTOL",
        [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN_PISTOL",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE_ANGRY_PISTOL",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_AIM_PISTOL",
                [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN_AIM_PISTOL"
        },
		[ "fire" ] = "ACT_GESTURE_RANGE_ATTACK_PISTOL",
        [ "reload" ] = "ACT_GESTURE_RELOAD_PISTOL"
}
Anims.Male[ "ar2" ] = {
        [ "idle" ] = "ACT_IDLE_SMG1_RELAXED",
        [ "walk" ] = "ACT_WALK_RIFLE_RELAXED",
        [ "run" ] = "ACT_RUN_RIFLE_RELAXED",
        [ "crouch" ] = {
                [ "idle" ] = "ACT_COVER_LOW",
                [ "walk" ] = "ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_AIM_RIFLE_STIMULATED",
                [ "walk" ] = "ACT_WALK_AIM_RIFLE_STIMULATED",
                [ "run" ] = "ACT_RUN_AIM_RIFLE_STIMULATED"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SMG1"
}

Anims.Male[ "smg" ] = {
        [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE_SMG1",
        [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_SMG1_LOW",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_SMG1_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE_ANGRY_SMG1",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_RIFLE",
                [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN_RIFLE"
        },
		[ "fire" ] = "ACT_GESTURE_RANGE_ATTACK_SMG1",
        [ "reload" ] = "ACT_GESTURE_RELOAD_SMG1"
}

Anims.Male[ "shotgun" ] = {
        [ "idle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_RANGE_AIM_AR2_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_IDLE_ANGRY_SHOTGUN",
                [ "walk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_AIM_SHOTGUN",
                [ "run" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_RUN_AIM_SHOTGUN"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SHOTGUN"
}

Anims.Male[ "crossbow" ] = {
        [ "idle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_RANGE_AIM_AR2_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_IDLE_ANGRY",
                [ "walk" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_WALK_AIM_RIFLE",
                [ "run" ] = "&switch:models/Gustavio/combineanimtree.mdl;ACT_RUN_AIM_RIFLE"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_AR2"
}

Anims.Male[ "rpg" ] = {
        [ "idle" ] = "ACT_IDLE_RPG",
        [ "walk" ] = "ACT_WALK_RPG_RELAXED",
        [ "run" ] = "ACT_RUN_RPG_RELAXED",
        [ "crouch" ] = {
                [ "idle" ] = "ACT_COVER_LOW_RPG",
                [ "walk" ] = "ACT_WALK_CROUCH_RPG",
                [ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_ANGRY_RPG",
                [ "walk" ] = "ACT_WALK_AIM_RIFLE_STIMULATED",
                [ "run" ] = "ACT_RUN_AIM_RIFLE_STIMULATED"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SMG1"
}

Anims.Male[ "melee" ] = {
        [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE_ANGRY_MELEE",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_ANGRY",
                [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN"
        },
		["fire"] = "ACT_MELEE_ATTACK_SWING_GESTURE"
}

Anims.Male[ "grenade" ] = {
        [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_IDLE_ANGRY_MELEE",
                [ "walk" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_WALK_ANGRY",
                [ "run" ] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_RUN"
        },
		["fire"] = "&switch:models/Gustavio/metroanimtree.mdl;ACT_COMBINE_THROW_GRENADE"
}

Anims.Male[ "slam" ] = {
        [ "idle" ] = "ACT_IDLE",
        [ "walk" ] = "ACT_WALK_SUITCASE",
        [ "run" ] = "ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "ACT_COVER_LOW",
                [ "walk" ] = "ACT_WALK_CROUCH",
                [ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "ACT_WALK_CROUCH_RPG"
                },
        [ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_PACKAGE",
                [ "walk" ] = "ACT_WALK_PACKAGE",
                [ "run" ] = "ACT_RUN"
        },
		["fire"] = "ACT_PICKUP_RACK"
}
 
 
Anims.Female = {}
Anims.Female[ "models" ] = {
	"models/alyx.mdl",
	"models/Gustavio/femaleanimtree.mdl",
	"models/Gustavio/alyxanimtree.mdl"
 
}
Anims.Female[ "default" ] = { 
        [ "idle" ] = "ACT_IDLE",
        [ "walk" ] = "ACT_WALK",
        [ "run" ] = "ACT_RUN",
        [ "jump" ] = "ACT_JUMP",
        [ "land" ] = "ACT_LAND",
        [ "fly" ] = "ACT_GLIDE",
        [ "sit" ] = "ACT_BUSY_SIT_CHAIR",
        [ "sitground" ] = "ACT_BUSY_SIT_GROUND",
        [ "flinch" ] = {
                ["explosion"] = "ACT_GESTURE_FLINCH_BLAST"
                },
		[ "crouch" ] = {
				[ "idle" ] = "ACT_COVER_LOW",
				[ "walk" ] = "ACT_WALK_CROUCH",
				[ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
				[ "aimwalk" ] = "ACT_WALK_CROUCH_AIM_RIFLE"
		},
		[ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_AIM_RIFLE_STIMULATED",
                [ "walk" ] = "ACT_WALK_AIM_RIFLE_STIMULATED",
                [ "run" ] = "ACT_RUN_AIM_RIFLE_STIMULATED"
        }
}
Anims.Female[ "pistol" ] = {
        [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_PISTOL",
        [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_ANGRY_PISTOL",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_AIM_PISTOL",
                [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN_AIM_PISTOL"
        },
		[ "fire" ] = "ACT_GESTURE_RANGE_ATTACK_PISTOL",
}
Anims.Female[ "ar2" ] = {
        [ "idle" ] = "ACT_IDLE_SMG1_RELAXED",
        [ "walk" ] = "ACT_WALK_RIFLE_RELAXED",
        [ "run" ] = "ACT_RUN_RIFLE_RELAXED",
        [ "crouch" ] = {
                [ "idle" ] = "ACT_COVER_LOW",
                [ "walk" ] = "ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_AIM_RIFLE_STIMULATED",
                [ "walk" ] = "ACT_WALK_AIM_RIFLE_STIMULATED",
                [ "run" ] = "ACT_RUN_AIM_RIFLE_STIMULATED"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SMG1"
}

Anims.Female[ "smg" ] = {
        [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_SMG1",
        [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_ANGRY_SMG1",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_AIM_RIFLE",
                [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN_AIM_RIFLE"
        },
		[ "fire" ] = "ACT_GESTURE_RANGE_ATTACK_SMG1",
}

Anims.Female[ "shotgun" ] = {
        [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_SHOTGUN_STIMULATED",
        [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_RIFLE_RELAXED",
        [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN_RIFLE_RELAXED",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RANGE_AIM_AR2_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_ANGRY_RPG",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_AIM_RIFLE",
                [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN_AIM_RIFLE"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SHOTGUN"
}

Anims.Female[ "crossbow" ] = {
        [ "idle" ] = "ACT_IDLE_SMG1_RELAXED",
        [ "walk" ] = "ACT_WALK_RIFLE_RELAXED",
        [ "run" ] = "ACT_RUN_RIFLE_RELAXED",
        [ "crouch" ] = {
                [ "idle" ] = "ACT_COVER_LOW",
                [ "walk" ] = "ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_AIM_RIFLE_STIMULATED",
                [ "walk" ] = "ACT_WALK_AIM_RIFLE_STIMULATED",
                [ "run" ] = "ACT_RUN_AIM_RIFLE_STIMULATED"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SMG1"
}

Anims.Female[ "rpg" ] = {
        [ "idle" ] = "ACT_IDLE_RPG",
        [ "walk" ] = "ACT_WALK_RPG_RELAXED",
        [ "run" ] = "ACT_RUN_RPG_RELAXED",
        [ "crouch" ] = {
                [ "idle" ] = "ACT_COVER_LOW_RPG",
                [ "walk" ] = "ACT_WALK_CROUCH_RPG",
                [ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_ANGRY_RPG",
                [ "walk" ] = "ACT_WALK_AIM_RIFLE_STIMULATED",
                [ "run" ] = "ACT_RUN_AIM_RIFLE_STIMULATED"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SMG1"
}

Anims.Female[ "melee" ] = {
        [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_MANNEDGUN",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_PACKAGE",
                [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN"
        },
		["fire"] = "ACT_MELEE_ATTACK_SWING"
}

Anims.Female[ "grenade" ] = {
        [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_ANGRY_PISTOL",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_PACKAGE",
                [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN"
        },
		["fire"] = "ACT_MELEE_ATTACK_SWING"
}

Anims.Female[ "grenade" ] = {
        [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_IDLE_ANGRY_MELEE",
                [ "walk" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_WALK_ANGRY",
                [ "run" ] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_RUN"
        },
		["fire"] = "&switch:models/Gustavio/alyxanimtree.mdl;ACT_COMBINE_THROW_GRENADE"
}

Anims.Female[ "slam" ] = {
        [ "idle" ] = "ACT_IDLE",
        [ "walk" ] = "ACT_WALK_SUITCASE",
        [ "run" ] = "ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "ACT_COVER_LOW",
                [ "walk" ] = "ACT_WALK_CROUCH",
                [ "aimidle" ] = "ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "ACT_WALK_CROUCH_RPG"
                },
        [ "aim" ] = {
                [ "idle" ] = "ACT_IDLE_PACKAGE",
                [ "walk" ] = "ACT_WALK_PACKAGE",
                [ "run" ] = "ACT_RUN"
        },
		["fire"] = "ACT_PICKUP_RACK"
}

local function FindEnumeration( actname )

	for k, v in pairs ( _E ) do
		if(  k == actname ) then
			return tonumber( v );
		end
	end
	
	return -1;

end

local function FindName( actnum )
	for k, v in pairs ( _E ) do
		if(  v == actnum ) then
			return tostring( k );
		end
	end
	
	return "ACT_IDLE";
end	

local function HandleSequence( ply, seq )

	if string.match( seq, "&" ) then
		if string.match( seq, "switch" ) then
			local exp = string.Explode( ";", string.gsub( seq, "&", "" ) )
			local exp2 = string.Explode( ":", exp[1] )
			local model = exp2[2]
			seq = exp[2]
			if( string.lower( ply:GetModel() ) != string.lower( model ) ) then
				ply:SetModel( model )
				return FindEnumeration( seq )
			end
		elseif string.match( seq, "lua" ) then
			local exp = string.Explode( ";", string.gsub( seq, "&", "" ) )
			local exp2 = string.Explode( ":", exp[1] )
			local sequence = exp2[2]
			ply:StopAllLuaAnimations()
			ply:SetLuaAnimation( sequence )
			return -1
		elseif string.match( seq, "sequence" ) then
			local exp = string.Explode( ":", string.gsub( seq, "&", "" ) )
			return ply:LookupSequence( exp[2] )
		elseif string.match( seq, "number" ) then
			local exp = string.Explode( ":", string.gsub( seq, "&", "" ) )
			return tonumber( exp[2] )
		end
	else
		
		if ply:GetModel() != "models/Gustavio/femaleanimtree.mdl" or ply:GetModel() != "models/Gustavio/maleanimtree.mdl" then
			if ply:GetNWBool( "charloaded", false ) then
				if( ply:GetNWString( "gender", "Male" ) == "Female" ) then
					ply:SetModel( "models/Gustavio/femaleanimtree.mdl" )
					--ply:SetMaterial( "null" )
					--ply:SetModel( "models/alyx.mdl" )
				else
					--ply:SetModel( "models/barney.mdl" )
					ply:SetModel( "models/Gustavio/maleanimtree.mdl" )
					--ply:SetMaterial( "null" )
				end
			else
				ply:SetModel( "models/Gustavio/maleanimtree.mdl" );
				--ply:SetMaterial( "null" )
				--ply:SetModel( "models/barney.mdl" )
			end
		end
		
	end
	
	
	return FindEnumeration( seq )
	
end

local function getgender( ply )


	local model = string.lower( ply:GetModel() )
	if table.HasValue( Anims.Female[ "models" ], string.lower( model ) ) or ply:GetNWString( "gender", "Male" ) == "Female" then
		return "Female"
	end
	
	return "Male"

end

local shotgunholdtypes = {
	"shotgun",
	"physgun"
	
}

local meleeholdtypes = {
	"passive",
	"knife",
	"melee2",
	"melee" 
}
		
local function DetectHoldType( act )
	if string.match(  act, "pistol" ) then
		return "pistol"
	end
	for k, v in pairs( shotgunholdtypes ) do
		if string.match( act, v ) then
			return "shotgun"
		end
	end
	for k, v in pairs( meleeholdtypes ) do
		if string.match( act, v ) then
			return "melee"
		end
	end
	if string.match(  act, "ar2" ) then
		return "ar2"
	end
	if string.match(  act, "smg" ) then
		return "smg"
	end
	if string.match(  act, "rpg" ) then
		return "rpg"
	end
	if string.match(  act, "grenade" ) then
		return "grenade"
	end
	if string.match(  act, "slam" ) then
		return "slam"
	end
	return "default"
	
end

function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed )
	local eye = ply:EyeAngles()
	ply:SetLocalAngles( eye )

	if CLIENT then
		ply:SetRenderAngles( eye ) 
	end
	
	local estyaw = math.Clamp( math.atan2(velocity.y, velocity.x) * 180 / 3.141592, -180, 180 )
	local myaw = math.NormalizeAngle(math.NormalizeAngle(eye.y) - estyaw)

	ply:SetPoseParameter("move_yaw", myaw * -1 ) 
	
	local len2d = velocity:Length2D()
	local rate = 1.0
	
	if len2d > 0.5 then
			rate =  ( ( len2d * 0.8 ) / maxseqgroundspeed )
	end
	
	rate = math.Clamp(rate, 0, 1.5)
        // you can obviously set your own playback rate
	
	ply:SetPlaybackRate( rate )
end

local function HandleLanding( ply )

	ply.CalcIdeal = ACT_LAND
	ply:Freeze( true )
	timer.Simple( 0.8, function()
		ply.m_bLanding = false
		ply:Freeze( false )
		ply:AnimRestartMainSequence()
	end)

end

function GM:HandlePlayerJumping( ply )

        
        // don't airwalk, pretend we're floating, but we can airwalk underwater
        if !ply.m_bJumping && !ply:OnGround() && ply:WaterLevel() <= 0 then
                ply.m_bJumping = true
                ply.m_bFirstJumpFrame = false
                ply.m_flJumpStartTime = CurTime()
        end
        
        if ply.m_bJumping then
				--print( "I'M FUCKING JUMPING" )
                if ply.m_bFirstJumpFrame then
                        ply.m_bFirstJumpFrame = false
                        ply:AnimRestartMainSequence()
                end
                
                if ply:WaterLevel() >= 2 then
                        ply.m_bJumping = false
                        ply:AnimRestartMainSequence()
				end
				
                if (CurTime() - ply.m_flJumpStartTime) > 0.6 then
                        if ply:OnGround() and !ply.m_bLanding then
							ply.m_bLanding = true
							ply:Freeze( true )
							timer.Simple( 0.3, function()
								ply.m_bLanding = false
								ply.m_bJumping = false
								ply:Freeze( false )
								/*
								ply.CalcSeqOverride = -1
								ply:AnimRestartMainSequence()*/
							end)
							return true
							--ply:AnimRestartMainSequence()
                        end
				else
					if ply:OnGround() and !ply.m_bLanding then
						ply.m_bJumping = false
                        ply:AnimRestartMainSequence()
					end
                end
                
                if ply.m_bJumping then
					if !ply.m_bLanding then
                        ply.CalcIdeal = HandleSequence( ply, Anims[ getgender( ply ) ][ "default" ][ "jump" ] )
					else
						ply.CalcIdeal = ACT_LAND
					end
                        return true
                end
        end
        
        return false
end
 
function GM:HandlePlayerDucking( ply, velocity )

		local holdtype = "default"
		if( ValidEntity(  ply:GetActiveWeapon() ) ) then
			holdtype = DetectHoldType( ply:GetActiveWeapon():GetHoldType() ) 
		end
        if ply:Crouching() then
			--print( "I'M FUCKING DUCKING" )
			if ply:GetNWBool( "aiming", false ) then
                local len2d = velocity:Length2D()
                if len2d > 0.5 then
                        ply.CalcIdeal =  HandleSequence( ply, Anims[ getgender( ply ) ][ holdtype ][ "crouch" ][ "aimwalk" ] )
                else
                        ply.CalcIdeal =  HandleSequence( ply, Anims[ getgender( ply ) ][ holdtype][ "crouch" ][ "aimidle" ] )
                end
			else
				local len2d = velocity:Length2D()
                
                if len2d > 0.5 then
						ply.CalcIdeal = HandleSequence( ply, Anims[ getgender( ply ) ][ holdtype ][ "crouch" ][ "walk" ] )
                else
                        ply.CalcIdeal = HandleSequence( ply, Anims[ getgender( ply ) ][ holdtype ][ "crouch" ][ "idle" ] )
                end
			end
			return true
        end
        
        return false
end
 
function GM:HandlePlayerSwimming( ply )

        if ply:WaterLevel() >= 2 then
		
				ply.CalcIdeal = HandleSequence( ply, Anims[ getgender( ply ) ][ "default" ][ "fly" ] )
				--print( "I'M FUCKING SWIMMING" )
                ply.m_bInSwim = true
        else
                ply.m_bInSwim = false
                if !ply.m_bFirstSwimFrame then
                        ply.m_bFirstSwimFrame = true
                end
        end
        
        return false
end
 
function GM:HandlePlayerDriving( ply )
 
        if ply:InVehicle() then
			--print( "I'M FUCKING DRIVING" )
			 local pVehicle = ply:GetVehicle()
            local class = pVehicle:GetClass()
                        
				if ( class == "prop_vehicle_prisoner_pod" && pVehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" ) then
                        ply.CalcIdeal = ACT_IDLE
                else
						ply.CalcIdeal = HandleSequence( ply, Anims[ getgender( ply ) ][ "default" ][ "sit" ] )
                end
                        
                return true
        end
        
        return false
end

function GM:CalcMainActivity( ply, velocity ) 
		local holdtype = "default"
		if( ValidEntity(  ply:GetActiveWeapon() ) ) then
			holdtype = DetectHoldType( ply:GetActiveWeapon():GetHoldType() ) 
		end
		--print( "I'M FUCKING SETTING THE HOLDTYPE TO " .. holdtype )
        ply.CalcIdeal = ACT_IDLE
        ply.CalcSeqOverride = -1
        
        if self:HandlePlayerDriving( ply ) ||
                self:HandlePlayerJumping( ply ) ||
                self:HandlePlayerDucking( ply, velocity ) ||
                self:HandlePlayerSwimming( ply ) then
				
		else
                local len2d = velocity:Length2D()
				
					if ply:GetNWBool( "aiming", false ) then
						if len2d > 180 then
							ply.CalcIdeal =  HandleSequence( ply, Anims[ getgender( ply ) ][  holdtype ][ "run" ] )
							--print( "I'M FUCKING RUNNING WHILE AIMING" )
						elseif len2d > 0.5 then
							--print( "I'M FUCKING WALKING WHILE AIMING" )
							ply.CalcIdeal =  HandleSequence( ply, Anims[ getgender( ply ) ][  holdtype ][ "aim" ][ "walk" ] )
						else
							--print( "I'M FUCKING STANDING WHILE AIMING" )
							ply.CalcIdeal  = HandleSequence( ply, Anims[ getgender( ply ) ][  holdtype ][ "aim" ][ "idle" ] )
						end
					else
						if len2d > 180 then
							--print( "I'M FUCKING RUNNING" )
							ply.CalcIdeal =  HandleSequence( ply, Anims[ getgender( ply ) ][  holdtype ][ "run" ] )
						elseif len2d > 0.5 then
							--print( "I'M FUCKING WALKING" )
							ply.CalcIdeal =  HandleSequence( ply, Anims[ getgender( ply ) ][  holdtype ][ "walk" ] )
						else
							--print( "I'M FUCKING STANDING" )
							ply.CalcIdeal =  HandleSequence( ply, Anims[ getgender( ply ) ][  holdtype ][ "idle" ] )
						end
					end


        end
        --print( tostring( ply.CalcSeqOverride ) .. " IS THE SEQUENCE!" )
        return ply.CalcIdeal, ply.CalcSeqOverride
end		
        
function GM:TranslateActivity( ply, act )
		
		--We're not translating through the weapon
		return act
		
end
 
function GM:DoAnimationEvent( ply, event, data )

		local holdtype = "default"
		if( ValidEntity(  ply:GetActiveWeapon() ) ) then
			holdtype = DetectHoldType( ply:GetActiveWeapon():GetHoldType() ) 
		end

        if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
				if Anims[ getgender( ply ) ][ holdtype ][ "fire" ] then
						if( string.match( Anims[ getgender( ply ) ][ holdtype ][ "fire" ], "GESTURE" ) ) then
								ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, FindEnumeration(  Anims[ getgender( ply ) ][ holdtype ][ "fire" ] ) ) -- Not a sequence, so I don't use HandleSequence here.
						else
								ply.CalcIdeal = HandleSequence( ply, Anims[ getgender( ply ) ][ holdtype ][ "fire" ] )
						end	
				else
						ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_RANGE_ATTACK_SMG1 )
				end

                return ACT_VM_PRIMARYATTACK
                
        elseif event == PLAYERANIMEVENT_RELOAD then
				if Anims[ getgender( ply ) ][ holdtype ][ "reload" ] then
						if( string.match( Anims[ getgender( ply ) ][ holdtype ][ "reload" ], "GESTURE" ) ) then
								ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, FindEnumeration(  Anims[ getgender( ply ) ][ holdtype ][ "reload" ] ) )
						else
								ply.CalcIdeal = HandleSequence( ply, Anims[ getgender( ply ) ][ holdtype ][ "reload" ] )
						end	
				else
                        ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_RELOAD_SMG1 )
				end
                
                return ACT_INVALID
		elseif event == PLAYERANIMEVENT_CANCEL_RELOAD then
        
                ply:AnimResetGestureSlot( GESTURE_SLOT_ATTACK_AND_RELOAD )
                
                return ACT_INVALID
        end
                
        if event == PLAYERANIMEVENT_JUMP then
        
                ply.m_bJumping = true
                ply.m_bFirstJumpFrame = true
                ply.m_flJumpStartTime = CurTime()
                
                ply:AnimRestartMainSequence()
                
                return ACT_INVALID
                
		end
 
        return nil
end