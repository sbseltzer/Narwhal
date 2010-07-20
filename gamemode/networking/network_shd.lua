
/*---------------------------------------------------------

	Developer's Notes:
	
	This file has our shared tables and entity methods.
	
	BUG: For some reason using the Entity metatable for
	methods isn't automatically adding it to the Player
	metatable. Wtf?

---------------------------------------------------------*/

// Declare frequently used globals as locals to enhance performance
local string = string
local math = math
local umsg = umsg
local type = type
local error = error
local pairs = pairs
local tonumber = tonumber
local tostring = tostring
local FindMetaTable = FindMetaTable

GM.__NetworkCache = {} -- Set up the shared Network Cache table
GM.__NetworkCache.Booleans = {} -- Stores NWBools
GM.__NetworkCache.Strings = {} -- Stores NWStrings
GM.__NetworkCache.Integers = {} -- Stores NWInts
GM.__NetworkCache.Floats = {} -- Stores NWFloats
GM.__NetworkCache.Entities = {} -- Stores NWEntities
GM.__NetworkCache.Colors = {} -- Stores NWColors
GM.__NetworkCache.Vectors = {} -- Stores NWVectors
GM.__NetworkCache.Angles = {} -- Stores NWAngles
GM.__NetworkCache.Effects = {} -- Stores NWEffects
GM.__NetworkCache.Tables = {} -- Stores NWTables
GM.__NetworkCache.Vars = {} -- Stores NWVars

function ents.GetByNetworkID( id )
	local eType, eID = id:sub( 1, 3 ), id:sub( 3 )
	if eType == "ent" then
		return ents.GetByIndex( eID )
	elseif eType == "ply" then
		return player.GetByUniqueID( eID )
	end
end

// Convenience function for strings that exceed the string character limit on umsg.String.
local function DivideString( str )
	local strList = {}
	local function Recur( str )
		local add, new
		if string.len( str ) > 127 then
			add = str:sub( 1, 127 )
			strList[strList+1] = add
			new = Recur( str:sub( 128 ) )
		else
			return str
		end
	end
	Recur( str )
	return strList
end

local function IsFloat( num )
	return tostring( num ):find( "." )
end

local function IsShort( num )
	num = tonumber( num )
	return ( num >= -32768 and num <= 32767 )
end

local function IsLong( num )
	num = tonumber( num )
	return ( num >= -2147483648 and num <= 2147483647 )
end

local function IsNormal( v )
	return ( ( v.x >= -1 and v.x <= 1 ) and ( v.y >= -1 and v.y <= 1 ) and ( v.z >= -1 and v.z <= 1 ) )
end

local function DivideNumber( num )
	num = tonumber( num )
	local numList = {}
	local function Recur( num )
		local add, new
		if !IsLong( num ) then
			if num < 0 then
				numList[numList+1] = tostring( num ):sub( 1, 11 )
				Recur( num:sub( 12 ) )
			else
				numList[numList+1] = tostring( num ):sub( 1, 10 )
				Recur( num:sub( 11 ) )
			end
		else
			return num
		end
	end
	Recur( num )
	return numList
end

GM.__NetworkData = {
	--[[ ["bool"] = {
		["Ref"] = "Bool",
		["Storage"] = "Booleans",
		["Func_Check"] = function( var )
			return
		end,
		["Func_Encode"] = function( var )
			var = tobool( var )
			return var
		end,
		["Func_Send"] = function( var )
			umsg.Bool( var )
		end,
		["Func_Recieve"] = function( um )
			return um:ReadBool()
		end
	},
	["string"] = {
		["Ref"] = "String",
		["Storage"] = "Strings",
		["Func_Check"] = function( var )
			if type( var ) != "string" and type( var ) != "number" then
				error( "Bad argument #2 (String expected, got "..type( var )..")\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			var = tostring( var )
			return DivideString( var )
		end,
		["Func_Send"] = function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				umsg.String( var )
			end
		end,
		["Func_Recieve"] = function( um )
			local s = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					s = s..um:ReadString()
				end
			else
				s = um:ReadString()
			end
			return s
		end
	},
	["integer"] = {
		["Ref"] = "Int",
		["Storage"] = "Integers",
		["Func_Check"] = function( var )
			if type( var ) != "string" and type( var ) != "number" then
				error( "Bad argument #2 (Number expected, got "..type( var )..")\n", 2 )
			elseif type( var ) == "string" and !tonumber( var ) then
				error( "Bad argument #2 (String '"..var.."' could not be converted to Number)\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			if IsFloat( var ) then
				var = tonumber( tostring( var ):sub( 1, IsFloat( var ) ) )
			end
			return DivideNumber( var )
		end,
		["Func_Send"] = function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.Long( v )
				end
			else
				umsg.Bool( false )
				if type(var) == "string" then
					umsg.Short( 1 )
					umsg.String( var )
				elseif type(var) == "number" then
					if IsShort( var ) then
						umsg.Short( 2 )
						umsg.Short( var )
					elseif IsLong( var ) then
						umsg.Short( 3 )
						umsg.Long( var )
					end
				end
			end
		end,
		["Func_Recieve"] = function( um )
			local n = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					n = n..um:ReadString()
				end
				n = tonumber( n )
			else
				local i = um:ReadShort()
				if i == 1 then
					n = tonumber( um:ReadString() )
				elseif i == 2 then
					n = um:ReadShort()
				else
					n = um:ReadLong()
				end
			end
			return n
		end
	},
	["float"] = {
		["Ref"] = "Float",
		["Storage"] = "Floats",
		["Func_Check"] = function( var )
			if type( var ) != "string" and type( var ) != "number" then
				error( "Bad argument #2 (Number expected, got "..type( var )..")\n", 2 )
			elseif type( var ) == "string" and !tonumber( var ) then
				error( "Bad argument #2 (String '"..var.."' could not be converted to Number)\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			if !IsLong( var ) then
				var = tostring( var )
			end
			var = tostring( var )
			return DivideString( var )
		end,
		["Func_Send"] = function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				if type( var ) == "string" then
					umsg.Short( 1 )
					umsg.String( var )
				elseif type(var) == "number" then
					umsg.Short( 2 )
					umsg.Float( var )
				end
			end
		end,
		["Func_Recieve"] = function( um )
			local n = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					n = n..um:ReadString()
				end
				n = tonumber( n )
			else
				local i = um:ReadShort()
				if i == 1 then
					n = tonumber( um:ReadString() )
				else
					n = um:ReadFloat()
				end
			end
			return n
		end
	},
	["entity"] = {
		["Ref"] = "Entity",
		["Storage"] = "Entities",
		["Func_Check"] = function( var )
			if type( var ) != "entity" and type( var ) != "player" then
				error( "Bad argument #2 (Player or Entity expected, got "..type( var )..")\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			return GAMEMODE:GetEntityNWID( var )
		end,
		["Func_Send"] = function( var )
			umsg.String( var )
		end,
		["Func_Recieve"] = function( um )
			local id = um:ReadString()
			local entType, entID, Ent = id:sub( 1, 3 ), id:sub( 3 )
			if entType == "ply" then
				Ent = player.GetByUniqueID( entID )
			elseif entType == "ent" then
				Ent = ents.GetByIndex( entID )
			end
			return Ent
		end
	},
	["color"] = {
		["Ref"] = "Color",
		["Storage"] = "Colors",
		["Func_Check"] = function( var )
			if type( var ) != "table" then
				error( "Bad argument #2 (Color expected, got "..type( var )..")\n", 2 )
			end
			local s = ""
			for k, v in pairs( Var ) do
				s = s..k
			end
			if s:sub( 1, 3 ) != "rgb" then
				error( "Bad argument #2 (Table '"..tostring(var).."' is not a valid Color)\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			var.r = math.Clamp( var.r, 0, 255 )
			var.g = math.Clamp( var.g, 0, 255 )
			var.b = math.Clamp( var.b, 0, 255 )
			var.a = var.a or 255
			var.a = math.Clamp( var.a, 0, 255 )
			return var
		end,
		["Func_Send"] = function( var )
			umsg.Short( var.r )
			umsg.Short( var.g )
			umsg.Short( var.b )
			umsg.Short( var.a )
		end,
		["Func_Recieve"] = function( um )
			local col = color_white
			col.r = um:ReadShort()
			col.g = um:ReadShort()
			col.b = um:ReadShort()
			col.a = um:ReadShort()
			return col
		end
	},
	["vector"] = {
		["Ref"] = "Vector",
		["Storage"] = "Vectors",
		["Func_Check"] = function( var )
			if type( var ) != "vector" then
				error( "Bad argument #2 (Vector expected, got "..type( var )..")\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			return var
		end,
		["Func_Send"] = function( var )
			umsg.Vector( var )
		end,
		["Func_Recieve"] = function( um )
			return um:ReadVector()
		end
	},
	["angle"] = {
		["Ref"] = "Angle",
		["Storage"] = "Angles",
		["Func_Check"] = function( var )
			if type( var ) != "angle" then
				error( "Bad argument #2 (Angle expected, got "..type( var )..")\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			return var
		end,
		["Func_Send"] = function( var )
			umsg.Angle( var )
		end,
		["Func_Recieve"] = function( um )
			return um:ReadAngle()
		end
	},
	["table"] = {
		["Ref"] = "Table",
		["Storage"] = "Tables",
		["Func_Check"] = function( var )
			if type( var ) != "table" then
				error( "Bad argument #2 (Table expected, got "..type( var )..")\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			var = glon.encode( var )
			return DivideString( var )
		end,
		["Func_Send"] = function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				umsg.String( var )
			end
		end,
		["Func_Recieve"] = function( um )
			local t = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					t = t..um:ReadString()
				end
			else
				t = um:ReadString()
			end
			return glon.decode(t)
		end
	},
	["ceffectdata"] = {
		["Ref"] = "Effect",
		["Storage"] = "Effects",
		["Func_Check"] = function( var )
			if type( var ) != "CEffectData" then
				error( "Bad argument #2 (CEffectData expected, got "..type( var )..")\n", 2 )
			end
		end,
		["Func_Encode"] = function( var )
			var = glon.encode( var )
			return DivideString( var )
		end,
		["Func_Send"] = function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				umsg.String( var )
			end
		end,
		["Func_Recieve"] = function( um )
			local t = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					t = t..um:ReadString()
				end
			else
				t = um:ReadString()
			end
			return glon.decode(t)
		end
	} ]]--
}

// This can be used to add custom datatypes. This could be useful on a per-gamemode basis. It would allow developers to design their own ways of sending data.
// Every time we send data, it follows a general pattern: Check to see if the data is valid within the context of the variable, Encode it somehow, Send that encoded data via usermessages, and then Retrieving that data on the client.
function GM:AddValidNetworkType( sType, sRef, sStore, funcCheck, funcEncode, funcSend, funcRetrieve )
	local tData = {}
	tData["Ref"] = sRef
	tData["Storage"] = sStore
	tData["Func_Check"] = funcCheck
	tData["Func_Encode"] = funcEncode
	tData["Func_Send"] = funcSend
	tData["Func_Retrieve"] = funcRetrieve
	GAMEMODE.__NetworkData[sType] = tData
end

function GM:GetNetworkConfigurations()
	return GAMEMODE.__NetworkData
end

function GM:LoadNetworkConfigurations()
	
end
function GM:LoadNetworkConfigurations_Internal()
	
	// BOOLEANS
	GAMEMODE:AddValidNetworkType( "boolean", "Bool", "Booleans",
		function( var ) return end,
		function( var ) return tobool( var ) end,
		function( var ) umsg.Bool( var ) end,
		function( um ) return um:ReadBool() end )

	// STRINGS
	GAMEMODE:AddValidNetworkType( "string", "String", "Strings",
		function( var )
			if type( var ) != "string" and type( var ) != "number" then
				error( "Bad argument #2 (String expected, got "..type( var )..")\n", 2 )
			end
		end,
		function( var ) return DivideString( tostring( var ) ) end,
		function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				umsg.String( var )
			end
		end,
		function( um )
			local s = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					s = s..um:ReadString()
				end
			else
				s = um:ReadString()
			end
			return s
		end )

	// INTEGERS
	GAMEMODE:AddValidNetworkType( "integer", "Int", "Integers",
		function( var )
			if type( var ) != "string" and type( var ) != "number" then
				error( "Bad argument #2 (Number expected, got "..type( var )..")\n", 2 )
			elseif type( var ) == "string" and !tonumber( var ) then
				error( "Bad argument #2 (String '"..var.."' could not be converted to Number)\n", 2 )
			end
		end,
		function( var )
			if IsFloat( var ) then
				var = tonumber( tostring( var ):sub( 1, IsFloat( var ) ) )
			end
			return DivideNumber( var )
		end,
		function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.Long( v )
				end
			else
				umsg.Bool( false )
				if type(var) == "string" then
					umsg.Short( 1 )
					umsg.String( var )
				elseif type(var) == "number" then
					if IsShort( var ) then
						umsg.Short( 2 )
						umsg.Short( var )
					elseif IsLong( var ) then
						umsg.Short( 3 )
						umsg.Long( var )
					end
				end
			end
		end,
		function( um )
			local n = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					n = n..um:ReadString()
				end
				n = tonumber( n )
			else
				local i = um:ReadShort()
				if i == 1 then
					n = tonumber( um:ReadString() )
				elseif i == 2 then
					n = um:ReadShort()
				else
					n = um:ReadLong()
				end
			end
			return n
		end )

	// FLOATS
	GAMEMODE:AddValidNetworkType( "float", "Float", "Floats",
		function( var )
			if type( var ) != "string" and type( var ) != "number" then
				error( "Bad argument #2 (Number expected, got "..type( var )..")\n", 2 )
			elseif type( var ) == "string" and !tonumber( var ) then
				error( "Bad argument #2 (String '"..var.."' could not be converted to Number)\n", 2 )
			end
		end,
		function( var )
			if !IsLong( var ) then
				var = tostring( var )
			end
			return DivideString( var )
		end,
		function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				if type( var ) == "string" then
					umsg.Short( 1 )
					umsg.String( var )
				elseif type(var) == "number" then
					umsg.Short( 2 )
					umsg.Float( var )
				end
			end
		end,
		function( um )
			local n = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					n = n..um:ReadString()
				end
				n = tonumber( n )
			else
				local i = um:ReadShort()
				if i == 1 then
					n = tonumber( um:ReadString() )
				else
					n = um:ReadFloat()
				end
			end
			return n
		end )

	// ENTITIES	
	GAMEMODE:AddValidNetworkType( "entity", "Entity", "Entities",
		function( var )
			if type( var ) != "entity" and type( var ) != "player" then
				error( "Bad argument #2 (Player or Entity expected, got "..type( var )..")\n", 2 )
			end
		end,
		function( var ) return GAMEMODE:GetEntityNWID( var ) end,
		function( var ) umsg.String( var ) end,
		function( um )
			local id = um:ReadString()
			local entType, entID, Ent = id:sub( 1, 3 ), id:sub( 3 )
			if entType == "ply" then
				Ent = player.GetByUniqueID( entID )
			elseif entType == "ent" then
				Ent = ents.GetByIndex( entID )
			end
			return Ent
		end )

	// COLORS
	GAMEMODE:AddValidNetworkType( "color", "Color", "Colors",
		function( var )
			if type( var ) != "table" then
				error( "Bad argument #2 (Color expected, got "..type( var )..")\n", 2 )
			end
			local s = ""
			for k, v in pairs( Var ) do
				s = s..k
			end
			if s:sub( 1, 3 ) != "rgb" then
				error( "Bad argument #2 (Table '"..tostring(var).."' is not a valid Color)\n", 2 )
			end
		end,
		function( var )
			var.r = math.Clamp( var.r, 0, 255 )
			var.g = math.Clamp( var.g, 0, 255 )
			var.b = math.Clamp( var.b, 0, 255 )
			var.a = var.a or 255
			var.a = math.Clamp( var.a, 0, 255 )
			return var
		end,
		function( var )
			umsg.Short( var.r )
			umsg.Short( var.g )
			umsg.Short( var.b )
			umsg.Short( var.a )
		end,
		function( um )
			local col = color_white
			col.r = um:ReadShort()
			col.g = um:ReadShort()
			col.b = um:ReadShort()
			col.a = um:ReadShort()
			return col
		end )

	// VECTORS
	GAMEMODE:AddValidNetworkType( "vector", "Vector", "Vectors",
		function( var )
			if type( var ) != "vector" then
				error( "Bad argument #2 (Vector expected, got "..type( var )..")\n", 2 )
			end
		end,
		function( var ) return var end,
		function( var ) umsg.Vector( var ) end,
		function( um ) return um:ReadVector() end )

	// ANGLES
	GAMEMODE:AddValidNetworkType( "angle", "Angle", "Angles",
		function( var )
			if type( var ) != "angle" then
				error( "Bad argument #2 (Angle expected, got "..type( var )..")\n", 2 )
			end
		end,
		function( var ) return var end,
		function( var ) umsg.Angle( var ) end,
		function( um ) return um:ReadAngle() end )

	// TABLES
	GAMEMODE:AddValidNetworkType( "table", "Table", "Tables",
		function( var )
			if type( var ) != "table" then
				error( "Bad argument #2 (Table expected, got "..type( var )..")\n", 2 )
			end
		end,
		function( var ) return DivideString( glon.encode( var ) ) end,
		function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				umsg.String( var )
			end
		end,
		function( um )
			local t = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					t = t..um:ReadString()
				end
			else
				t = um:ReadString()
			end
			return glon.decode(t)
		end )

	// EFFECTS
	GAMEMODE:AddValidNetworkType( "ceffectdata", "Effect", "Effects",
		function( var )
			if type( var ) != "CEffectData" then
				error( "Bad argument #2 (CEffectData expected, got "..type( var )..")\n", 2 )
			end
		end,
		function( var ) return DivideString( glon.encode( var ) ) end,
		function( var )
			if type(var) == "table" then
				umsg.Bool( true )
				umsg.Short( #var )
				for k, v in pairs( var ) do
					umsg.String( v )
				end
			else
				umsg.Bool( false )
				umsg.String( var )
			end
		end,
		function( um )
			local t = ""
			if um:ReadBool() then
				for i = 1, um:ReadShort() do
					t = t..um:ReadString()
				end
			else
				t = um:ReadString()
			end
			return glon.decode(t)
		end )
	
	GAMEMODE:LoadNetworkConfigurations() -- Call the one for developers.
	
	local ENTITY = FindMetaTable( "Entity" ) -- Here is the entity metatable. This lets us add methods to all entities.

	if !ENTITY then return end
	
	function ENTITY:GetNetworkID()
		if self:IsPlayer() then
			return "ply"..self:UniqueID()
		else
			return "ent"..self:EntIndex()
		end
	end

	for k, v in pairs( GAMEMODE.__NetworkData ) do
		ENTITY["SendNetworked"..v.Ref] = function( self, Name, Var, Filter )
			if !self or !ValidEntity( self ) or ( type( self ):lower() != "entity" and type( self ):lower() != "player" ) then
				error( "Bad argument #1 (Entity or Player expected, got "..type( self )..")\n", 2 )
			elseif !Name then
				error( "Bad argument #2 (String or Number expected, got "..type( Name )..")\n", 2 )
			elseif Name:find('[\\/:%*%?"<>|]') or Name:find(" ") then
				error( "Bad argument #2 (Variable Names may only contain alphanumeric characters and underscores!)\n", 2 )
			elseif !Var then
				error( "Bad argument #3 (Attempted to use nil variable!)\n", 2 )
			end
			print( self, Name, Var, k, Filter )
			return GAMEMODE:FetchNetworkedVariable( self, Name, Var, k, Filter )
		end
		ENTITY["FetchNetworked"..v.Ref] = function( self, Name, Var, Filter )
			if !self or !ValidEntity( self ) or ( type( self ):lower() != "entity" and type( self ):lower() != "player" ) then
				error( "Bad argument #1 (Entity or Player expected, got "..type( self )..")\n", 2 )
			elseif !Name then
				error( "Bad argument #2 (String or Number expected, got "..type( Name )..")\n", 2 )
			elseif Name:find('[\\/:%*%?"<>|]') or Name:find(" ") then
				error( "Bad argument #2 (Variable Names may only contain alphanumeric characters and underscores!)\n", 2 )
			elseif !Var then
				error( "Bad argument #3 (Attempted to use nil variable!)\n", 2 )
			end
			return GAMEMODE:FetchNetworkedVariable( self, Name, Var, k, Filter )
		end
		ENTITY["SendNW"..v.Ref] = ENTITY["SendNetworked"..v.Ref]
		ENTITY["FetchNW"..v.Ref] = ENTITY["FetchNetworked"..v.Ref]
	end
	
end








