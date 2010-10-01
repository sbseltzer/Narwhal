--Hey hey hey! It's fucking NPC animations version three! This time with no Rick Dark shit.
--Credits to Azuisleet ( Original hook ), Entoros( Holdtype thing -- Which is no more, since garry added that in :/ ), and well, me, Big Bang/F-Nox ( everything else )

local meta = FindMetaTable( "Player" )
function meta:GetBodyEntity()
	return self:GetNWEntity( "player_body" )
end
function meta:CreateBodyEntity( mdl )
	mdl = mdl or player_manager.TranslatePlayerModel( self:GetInfo( "cl_playermodel" ) )
	if IsValid( self:GetBodyEntity() ) then
		return
	end
	local body = ents.Create( "narwhal_playerbody" )
	body:SetPos( self:GetPos() )
	body:SetAngles( self:GetAngles() )
	body:SetModel( mdl )
	body:SetParent( self )
	body:Spawn()
	self:SetNWEntity( "player_body", body ) -- Oh no, we aren't using our custom networking!
	self:SetColor( Color( 255, 255, 255, 254 ) )
end
function meta:SetBodyModel( mdl )
	local b = self:GetBodyEntity()
	self:SetNWString( "NARWHAL_PlayerBodyModel", mdl )
	if IsValid( b ) then
		b:SetModel( mdl )
	end
end
function meta:GetBodyModel()
	local b = self:GetBodyEntity()
	if IsValid( b ) then
		if self:GetNWString( "NARWHAL_PlayerBodyModel" ) != b:GetModel() then
			self:SetNWString( "NARWHAL_PlayerBodyModel", b:GetModel() )
		end
	end
	return self:GetNWString( "NARWHAL_PlayerBodyModel" )
end

hook.Add( "PlayerSpawn", "NARWHAL.PlayerSpawn.HandlePlayerBody", function( ply )
	if NARWHAL.Config.UseAnims == true then
		ply:CreateBodyEntity()
		ply:SetBodyModel( player_manager.TranslatePlayerModel( ply:GetInfo( "cl_playermodel" ) ) )
	end
end )
hook.Add( "PlayerDeath", "NARWHAL.PlayerDeath.HandlePlayerBody", function( ply )
	if NARWHAL.Config.UseAnims == true then
		--ply:GetBodyModel():SetParent( ply:GetRagdollEntity() )
		ply:GetRagdollEntity():SetModel( ply:GetBodyModel() )
		SafeRemoveEntity( ply:GetBodyEntity() )
	end
end )

function NARWHAL:AddAnimation( gender, holdtype, activity, state, animtype, ... )
	
	if gender == "Female" or gender:lower() == "female" then
		gender = "Female"
	elseif gender == "Male" or gender:lower() == "male" then
		gender = "Male"
	end
	
	local animdata = {...}
	local animstring = ""
	
	if animtype and ( animtype == "switch" or animtype == "lua" or animtype == "sequence" or animtype == "number" ) then
		animstring = "&"..animtype..":"
		if animtype == "switch" then
			if animdata[1]:sub( -4 ) != ".mdl" then
				return
			end
			animstring = animstring..animdata[1]..";"..animdata[2]
		elseif animtype == "lua" then
			-- not sure how these work
			animstring = animstring..animdata[1]..";"..animdata[2]
		elseif animtype == "sequence" then
			-- not sure how these worka[1
		elseif animtype == "number" then
			-- not sure how these work
		end
	else
		animstring = animdata[1]
	end
	
	if state and Anims[gender][holdtype][activity] then
		Anims[gender][holdtype][activity][state] = animstring
	else
		Anims[gender][holdtype][activity] = animstring
	end
	
end

local meta = FindMetaTable("Player")
function meta:GetGender()

	local model = string.lower( self:GetModel() )
	if table.HasValue( Anims.Female[ "models" ], string.lower( model ) ) or self:GetNWString( "gender", "Male" ) == "Female" then
		return "Female"
	end
	
	return "Male"

end

if SERVER then
	--Weapons that are always aimed
	AlwaysAimed = {
		"weapon_physgun",
		"weapon_physcannon",
		"weapon_frag",
		"weapon_slam",
		"weapon_rpg",
		"gmod_tool"
	}

	--Weapons that are never aimed
	NeverAimed = {
		"hands"
	}

	function meta:SetAiming( bool )
		local wep = self:GetActiveWeapon()
		if self:GetNWBool( "arrested", false ) then
			bool = false
		end
		if ValidEntity( wep ) then
			if table.HasValue( AlwaysAimed, wep:GetClass() ) then
				bool = true
			end
			if table.HasValue( NeverAimed, wep:GetClass() ) then
				bool = false
			end
			if bool then
				wep:SetNextPrimaryFire( CurTime() )
			else
				wep:SetNextPrimaryFire( CurTime() + 999999 )
			end
		end
		self:DrawViewModel( bool )
		self:SetNWBool( "aiming", bool )
	end
	
	local function HolsterToggle( ply, cmd, args )
		ply:SetAiming( !ply:GetAiming() )
	end
	concommand.Add( "rp_toggleholster", HolsterToggle );
	concommand.Add( "toggleholster", HolsterToggle );
	
end

function meta:GetAiming()
	if self:GetNWBool( "aiming", false ) then
		return true
	end
	
	return false
end

meta = nil

Anims = {}
Anims.Male = {}
Anims.Male[ "models" ] = {
	"models/Skeleton/maleanimtree.mdl"
}
Anims.Male[ "default" ] = { 
        [ "idle" ] = "ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/barneyanimtree.mdl;ACT_WALK",
        [ "run" ] = "&lua:aaaa2;",
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
        [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE_PISTOL",
        [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_PISTOL",
        [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN_PISTOL",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE_ANGRY_PISTOL",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_AIM_PISTOL",
                [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN_AIM_PISTOL"
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
        [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE_SMG1",
        [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_SMG1_LOW",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_SMG1_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE_ANGRY_SMG1",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_RIFLE",
                [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN_RIFLE"
        },
		[ "fire" ] = "ACT_GESTURE_RANGE_ATTACK_SMG1",
        [ "reload" ] = "ACT_GESTURE_RELOAD_SMG1"
}

Anims.Male[ "shotgun" ] = {
        [ "idle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_RANGE_AIM_AR2_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_IDLE_ANGRY_SHOTGUN",
                [ "walk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_AIM_SHOTGUN",
                [ "run" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_RUN_AIM_SHOTGUN"
        },
		["fire"] = "ACT_GESTURE_RANGE_ATTACK_SHOTGUN"
}

Anims.Male[ "crossbow" ] = {
        [ "idle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_RANGE_AIM_AR2_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_CROUCH_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_IDLE_ANGRY",
                [ "walk" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_WALK_AIM_RIFLE",
                [ "run" ] = "&switch:models/Skeleton/combineanimtree.mdl;ACT_RUN_AIM_RIFLE"
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
        [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE_ANGRY_MELEE",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_ANGRY",
                [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN"
        },
		["fire"] = "ACT_MELEE_ATTACK_SWING_GESTURE"
}

Anims.Male[ "grenade" ] = {
        [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_IDLE_ANGRY_MELEE",
                [ "walk" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_WALK_ANGRY",
                [ "run" ] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_RUN"
        },
		["fire"] = "&switch:models/Skeleton/metroanimtree.mdl;ACT_COMBINE_THROW_GRENADE"
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
	"models/Skeleton/femaleanimtree.mdl"
}
Anims.Female[ "default" ] = { 
        [ "idle" ] = "ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK",
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
        [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_PISTOL",
        [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_ANGRY_PISTOL",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_AIM_PISTOL",
                [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN_AIM_PISTOL"
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
        [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_SMG1",
        [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_RIFLE",
        [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN_RIFLE",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH_AIM_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_ANGRY_SMG1",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_AIM_RIFLE",
                [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN_AIM_RIFLE"
        },
		[ "fire" ] = "ACT_GESTURE_RANGE_ATTACK_SMG1",
}

Anims.Female[ "shotgun" ] = {
        [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_SHOTGUN_STIMULATED",
        [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_RIFLE_RELAXED",
        [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN_RIFLE_RELAXED",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH_RIFLE",
                [ "aimidle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RANGE_AIM_SMG1_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH_RIFLE"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_ANGRY_RPG",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_AIM_RIFLE",
                [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN_AIM_RIFLE"
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
        [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_MANNEDGUN",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_PACKAGE",
                [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN"
        },
		["fire"] = "ACT_MELEE_ATTACK_SWING"
}

Anims.Female[ "grenade" ] = {
        [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE",
        [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK",
        [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN",
        [ "crouch" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_COVER_LOW",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH",
                [ "aimidle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_COVER_PISTOL_LOW",
                [ "aimwalk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_CROUCH"
                },
        [ "aim" ] = {
                [ "idle" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_IDLE_ANGRY_PISTOL",
                [ "walk" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_WALK_PACKAGE",
                [ "run" ] = "&switch:models/Skeleton/alyxanimtree.mdl;ACT_RUN"
        },
		["fire"] = "ACT_MELEE_ATTACK_SWING"
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

local function FindEnumeration( actname ) --Finds the enumeration number based on it's name.

	for k, v in pairs ( _E ) do
		if(  k == actname ) then
			return tonumber( v );
		end
	end
	
	return -1;

end

local function FindName( actnum ) --Finds the enumeration name based on it's number.
	for k, v in pairs ( _E ) do
		if(  v == actnum ) then
			return tostring( k );
		end
	end
	
	return "ACT_IDLE";
end	

local function HandleLuaAnimation( ply, animation )
	
	if CLIENT then
		if !ply.InLuaSequence then
			ply.InLuaSequence = true
			ply:SetLuaAnimation( animation )
			print( animation )
		end
	end
	
end

local function HandleSequence( ply, seq ) --Internal function to handle different sequence types.
	
	if string.match( seq, "&" ) then
		if string.match( seq, "lua" ) then
			local exp = string.Explode( ";", string.gsub( seq, "&", "" ) )
			local exp2 = string.Explode( ":", exp[1] )
			local sequence = exp2[2]
			HandleLuaAnimation( ply, sequence )
			return ACT_DIERAGDOLL
		else
			if ply.InLuaSequence then
				if CLIENT then
					ply:StopAllLuaAnimations()
				end
				ply.InLuaSequence = false
			end
		end
		if string.match( seq, "switch" ) then --Internal handler used to switch skeletons.
			local exp = string.Explode( ";", string.gsub( seq, "&", "" ) )
			local exp2 = string.Explode( ":", exp[1] )
			local model = exp2[2]
			seq = exp[2]
			if( string.lower( ply:GetModel() ) != string.lower( model ) and !ply:GetNWBool( "specialmodel", false ) ) then
				ply:SetModel( model )
				return FindEnumeration( seq )
			end
		elseif string.match( seq, "sequence" ) then
			local exp = string.Explode( ":", string.gsub( seq, "&", "" ) ) --This two don't work very well yet
			return ply:LookupSequence( exp[2] )
		elseif string.match( seq, "number" ) then
			local exp = string.Explode( ":", string.gsub( seq, "&", "" ) )
			return tonumber( exp[2] )
		end
	else
		
		if ( ply:GetModel() != "models/Skeleton/femaleanimtree.mdl" or ply:GetModel() != "models/Skeleton/maleanimtree.mdl" ) then
			if !ply:GetNWBool( "specialmodel", false ) then
				if( ply:GetGender() == "Female" ) then
					ply:SetModel( "models/Skeleton/femaleanimtree.mdl" )
				else
					ply:SetModel( "models/Skeleton/maleanimtree.mdl" )
				end
			else
				ply:SetModel( "models/Skeleton/maleanimtree.mdl" );
			end
		end
	end
	
	
	return FindEnumeration( seq )
	
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
		
local function DetectHoldType( act ) --This is just a function used to group up similar holdtype for them to use the same sequences, since NPC animations are kinda limited.
	--You can add or remove to this list as you see fit, if you feel like creating a different holdtype.
	
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

function GM:UpdateAnimation( ply, velocity, maxseqgroundspeed ) -- This handles everything about how sequences run, the framerate, boneparameters, everything.
	local eye = ply:EyeAngles()
	ply:SetLocalAngles( eye )
	ply:SetEyeTarget( ply:EyePos( ) )

	if CLIENT then
		ply:SetRenderAngles( eye )
	end
	
	local estyaw = math.Clamp( math.atan2(velocity.y, velocity.x) * 180 / 3.141592, -180, 180 )
	local myaw = math.NormalizeAngle(math.NormalizeAngle(eye.y) - estyaw)

	ply:SetPoseParameter("move_yaw", myaw * -1 )
	--This huge set of boneparameters are all set to 0 to avoid having the engine setting them to something else, thus resulting in  awkwardly twisted models
	ply:SetPoseParameter("aim_yaw", 0 )
	ply:SetPoseParameter("body_yaw", 0 )
	ply:SetPoseParameter("spine_yaw", 0 )
	ply:SetPoseParameter("head_roll", 0 )
	
	local len2d = velocity:Length2D() --Velocity in the x and y axis
	local rate = 1.0
	
	if len2d > 0.5 then
			rate =  ( ( len2d * 0.8 ) / maxseqgroundspeed )
	end
	
	rate = math.Clamp(rate, 0, 1.5)	
	ply:SetPlaybackRate( rate )
	
end

function GM:HandlePlayerJumping( ply ) --Handles jumping

        
        --If we're not on the ground, then play the gliding animation.
        if !ply.Jumping and !ply:OnGround() then
                ply.Jumping = true
                ply.FirstJumpFrame = false
                ply.JumpStartTime = CurTime()
        end
        
        if ply.Jumping then
                if ply.FirstJumpFrame then
                        ply.FirstJumpFrame = false
                        ply:AnimRestartMainSequence()
                end
                
                if ply:WaterLevel() >= 2 then
                        ply.Jumping = false
                        ply:AnimRestartMainSequence()
				end
				
                if (CurTime() - ply.JumpStartTime) > 0.4 then --If we have been on the air for more than 0.4 seconds, then we're meant to play the land animation.
                    if ply:OnGround() and !ply.Landing and !ply:GetNWBool( "observe" ) then
							ply.Landing = true
							timer.Simple( 0.3, function()
									ply.Landing = false
									ply.Jumping = false
							end)
						return true
                    end
				else
					if ply:OnGround() and !ply.Landing then
						ply.Jumping = false
                        ply:AnimRestartMainSequence()
					end
                end
                
                if ply.Jumping then --If we're still on a part of the jumping sequence, that means we're either on the process of jumping or landing.
					if !ply.Landing then 
                        ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ "default" ][ "jump" ] )
					else
						ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ "default" ][ "land" ] )
					end
                    return true
                end
        end
        
        return false
end
 
function GM:HandlePlayerDucking( ply, velocity ) --Handles crouching

		local holdtype = "default"
		if( ValidEntity(  ply:GetActiveWeapon() ) ) then
			holdtype = DetectHoldType( ply:GetActiveWeapon():GetHoldType() ) 
		end
        if ply:Crouching() then
			if ply:GetNWBool( "aiming", false ) then
                local len2d = velocity:Length2D() -- the velocity on the x and y axis.
                if len2d > 0.5 then
                        ply.CalcIdeal =  HandleSequence( ply, Anims[ ply:GetGender() ][ holdtype ][ "crouch" ][ "aimwalk" ] )
                else
                        ply.CalcIdeal =  HandleSequence( ply, Anims[ ply:GetGender() ][ holdtype][ "crouch" ][ "aimidle" ] )
                end
			else
				local len2d = velocity:Length2D()
                
                if len2d > 0.5 then
						ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ holdtype ][ "crouch" ][ "walk" ] )
                else
                        ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ holdtype ][ "crouch" ][ "idle" ] )
                end
			end
			return true
        end
        
        return false
end
 
function GM:HandlePlayerSwimming( ply ) --Handles swimming.

        if ply:WaterLevel() >= 2 then
				ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ "default" ][ "fly" ] )
				return true
		end
        
        return false
end
 
function GM:HandlePlayerDriving( ply ) --Handles sequences while in vehicles.
 
        if ply:InVehicle() then
			local vehicle = ply:GetVehicle()
            local class = vehicle:GetClass()
			if ( class == "prop_vehicle_prisoner_pod" and vehicle:GetModel() == "models/vehicles/prisoner_pod_inner.mdl" ) then
					ply.CalcIdeal = ACT_IDLE
            else
					ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ "default" ][ "sit" ] )
            end

            return true
		end
end

function GM:HandleExtraActivities( ply ) --Drop in here everything additional you need checks for.

	--Use this hook for all the other sequenced activities you may wanna add, like uh, flying I guess.

		if ply:GetNWBool( "sittingchair", false ) then
			if !ply.IsSittingDamn then
				ply.CalcIdeal = ACT_BUSY_SIT_CHAIR_ENTRY
				timer.Simple( 1.5, function()
					ply.IsSittingDamn = true
				end)
				return true
			else
				ply.CalcIdeal = ACT_BUSY_SIT_CHAIR
				return true
			end
		else
			if ply.IsSittingDamn then
				ply.CalcIdeal = ACT_BUSY_SIT_CHAIR_EXIT
				timer.Simple( 0.8, function()
					ply.IsSittingDamn = false
				end)
				return true
			end
		end
		
		if ply:GetNWBool( "sittingground", false ) then
			if !ply.IsSittingGround then
				ply.CalcIdeal = ACT_BUSY_SIT_GROUND_ENTRY
				timer.Simple( 2, function()
					ply.IsSittingGround = true
				end)
				return true
			else
				ply.CalcIdeal = ACT_BUSY_SIT_GROUND
				return true
			end
		else
			if ply.IsSittingGround then
				ply.CalcIdeal = ACT_BUSY_SIT_GROUND_EXIT
				timer.Simple( 1.4, function()
					ply.IsSittingGround = false
				end)
				return true
			end
		end
        
        return false

end

function GM:CalcMainActivity( ply, velocity )
		--This is the hook used to handle sequences, if you need to add additional activities you should check the hook above.
		--By a general rule you don't have to touch this hook at all.
		local holdtype = "default"
		if( ValidEntity(  ply:GetActiveWeapon() ) ) then
			holdtype = DetectHoldType( ply:GetActiveWeapon():GetHoldType() ) 
		end
        ply.CalcIdeal = ACT_IDLE
        ply.CalcSeqOverride = -1
        
        if self:HandlePlayerDriving( ply ) or
                self:HandlePlayerJumping( ply ) or
                self:HandlePlayerDucking( ply, velocity ) or
                self:HandlePlayerSwimming( ply ) or self:HandleExtraActivities( ply ) then
			--We do nothing, I guess, lol.
		else
            local len2d = velocity:Length2D()
				
			if ply:GetNWBool( "aiming", false ) then
				if len2d > 180 then
					ply.CalcIdeal =  HandleSequence( ply, Anims[ ply:GetGender() ][  holdtype ][ "run" ] )
				elseif len2d > 0.5 then
					ply.CalcIdeal =  HandleSequence( ply, Anims[ ply:GetGender() ][  holdtype ][ "aim" ][ "walk" ] )
				else
					ply.CalcIdeal  = HandleSequence( ply, Anims[ ply:GetGender() ][  holdtype ][ "aim" ][ "idle" ] )
				end
			else
				if len2d > 180 then
					ply.CalcIdeal =  HandleSequence( ply, Anims[ ply:GetGender() ][  holdtype ][ "run" ] )
				elseif len2d > 0.5 then
					ply.CalcIdeal =  HandleSequence( ply, Anims[ ply:GetGender() ][  holdtype ][ "walk" ] )
				else
					ply.CalcIdeal =  HandleSequence( ply, Anims[ ply:GetGender() ][  holdtype ][ "idle" ] )
				end
			end


        end
        return ply.CalcIdeal, ply.CalcSeqOverride
end		
        
function GM:TranslateActivity( ply, act )
		
		--We're not translating through the weapon, thus, this hook isn't used.
		return act
		
end
 
function GM:DoAnimationEvent( ply, event, data ) -- This is for gestures.

		local holdtype = "default"
		if( ValidEntity(  ply:GetActiveWeapon() ) ) then
			holdtype = DetectHoldType( ply:GetActiveWeapon():GetHoldType() ) 
		end

        if event == PLAYERANIMEVENT_ATTACK_PRIMARY then
				if Anims[ ply:GetGender() ][ holdtype ][ "fire" ] then
						if( string.match( Anims[ ply:GetGender() ][ holdtype ][ "fire" ], "GESTURE" ) ) then
								ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, FindEnumeration(  Anims[ ply:GetGender() ][ holdtype ][ "fire" ] ) ) -- Not a sequence, so I don't use HandleSequence here.
						else
								ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ holdtype ][ "fire" ] )
						end	
				else
						ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, ACT_GESTURE_RANGE_ATTACK_SMG1 )
				end

                return ACT_VM_PRIMARYATTACK
                
        elseif event == PLAYERANIMEVENT_RELOAD then
				if Anims[ ply:GetGender() ][ holdtype ][ "reload" ] then
						if( string.match( Anims[ ply:GetGender() ][ holdtype ][ "reload" ], "GESTURE" ) ) then
								ply:AnimRestartGesture( GESTURE_SLOT_ATTACK_AND_RELOAD, FindEnumeration(  Anims[ ply:GetGender() ][ holdtype ][ "reload" ] ) )
						else
								ply.CalcIdeal = HandleSequence( ply, Anims[ ply:GetGender() ][ holdtype ][ "reload" ] )
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
        
                ply.Jumping = true
                ply.FirstJumpFrame = true
                ply.JumpStartTime = CurTime()
                
                ply:AnimRestartMainSequence()
                
                return ACT_INVALID
                
		end
 
        return nil
end
