
/*---------------------------------------------------------

	Developer's Notes:
	
	Serverside Networking.
	This sends info to the client.
	
	SUPPORTED DATATYPES:
		Numbers (Ints and Floats)
		Strings
		Booleans
		Vectors
		Angles
		Colors
		Entities
		CEffectData
		Tables

---------------------------------------------------------*/

// Declare frequently used globals as locals to enhance performance
local string = string
local umsg = umsg
local type = type
local pairs = pairs
local error = error
local RecipientFilter = RecipientFilter
local ValidEntity = ValidEntity

// SERVER version of SendNetworkedVariable.
function GM:SendNetworkedVariable( Ent, Name, Var, storageType, Filter )
	
	print( Ent, Name, Var, storageType, Filter )
	
	
	print("no errors... yet")
	
	storageType = storageType or "var"
	
	local realType = type( Var )
	local SendData = GAMEMODE.__NetworkData[storageType]
	local storageDest = SendData.Storage
	local ID = Ent:GetNetworkID()
	
	if !GAMEMODE.__NetworkCache[storageDest] then
		GAMEMODE.__NetworkCache[storageDest] = {}
	end
	if !GAMEMODE.__NetworkCache[storageDest][ID] then
		GAMEMODE.__NetworkCache[storageDest][ID] = {}
	end
	if !GAMEMODE.__NetworkCache[storageDest][ID][Name] then
		GAMEMODE.__NetworkCache[storageDest][ID][Name] = {}
	end
	
	Filter = Filter or GAMEMODE.__NetworkCache[storageDest][ID][Name].Filter
	
	if !Filter then
		RF = RecipientFilter()
		RF:AddAllPlayers()
		Filter = RF
	end
	
	GAMEMODE.__NetworkCache[storageDest][ID][Name].Filter = Filter -- Update the filter settings.
	GAMEMODE.__NetworkCache[storageDest][ID][Name].Value = Var
	
	if SendData.Func_Check( Var ) == false then return end
	Var = SendData.Func_Encode( Var )
	
	umsg.Start( "NETWORK_SendVariable", RF )
		umsg.String( ID .. " " .. storageType .. --[[" " .. realType ..]] " " .. Name ) -- Is realtype even needed?
		SendData.Func_Send( Var )
	umsg.End()
	
end

// SERVER version of FetchNetworkedVariable.
function GM:FetchNetworkedVariable( Ent, Name, Var, storageType, Filter )
	
	// We don't want to go any further if some of our args are invalid
	if !Ent or !ValidEntity( Ent ) or ( string.lower( type( Ent ) ) != "entity" and string.lower( type( Ent ) ) != "player" ) then
		error( "Bad argument #1 (Entity or Player expected, got "..type( Ent )..")\n", 4 )
	elseif !Name then
		error( "Bad argument #2 (String or Number expected, got "..type( Name )..")\n", 4 )
	elseif !Var then
		error( "Bad argument #3 (Attempted to use nil variable!)\n", 4 )
	end
	
	storageType = storageType or "var"
	
	local ID = Ent:GetNetworkID()
	
	local storageDest = GAMEMODE:GetNetworkConfigurations()[storageType].Storage
	
	if !GAMEMODE.__NetworkCache[storageDest] then
		GAMEMODE.__NetworkCache[storageDest] = {}
	end
	if !GAMEMODE.__NetworkCache[storageDest][ID] then
		GAMEMODE.__NetworkCache[storageDest][ID] = {}
	end
	if !GAMEMODE.__NetworkCache[storageDest][ID][Name] then
		GAMEMODE.__NetworkCache[storageDest][ID][Name] = {}
		Filter = Filter or GAMEMODE.__NetworkCache[storageDest][ID][Name].Filter
		if !Filter then
			local RF = RecipientFilter()
			RF:AddAllPlayers()
			Filter = RF
		end
		GAMEMODE:SendNetworkedVariable( Ent, Name, Var, storageType, Filter )
		return Var
	end
	
	return GAMEMODE.__NetworkCache[storageDest][ID][Name].Value
	
end

/*
// Deletes a networked variable from the cache
function GM:DeleteNetworkedVariable( Ent, Name, storageType )
	
	local ID = Ent:GetNetworkID()
	local storageDest = GAMEMODE.__NetworkTypeTranslateTable[storageType]
	GAMEMODE.__NetworkCache[storageDest][ID][Name] = nil
	
	umsg.Start( "NETWORK_RemoveVariable" )
		umsg.String( ID .. " " .. storageType .. " " .. Name )
	umsg.End()
	
end
// Deletes all networked variables for an entity (entity is removed from cache)
function GM:RemoveEntityIndex( Ent )
	
	umsg.Start( "NETWORK_RemoveIndex" )
		umsg.String( Ent:GetNetworkID() )
	umsg.End()
	
end
*/









