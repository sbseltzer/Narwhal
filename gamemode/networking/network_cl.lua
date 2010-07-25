
/*---------------------------------------------------------

	Developer's Notes:
	
	Clientside Networking.
	This recieves networked data from the server.

---------------------------------------------------------*/

// Declare frequently used globals as locals to enhance performance
local string = string
local usermessage = usermessage
local pairs = pairs
local tonumber = tonumber
local color_white = color_white

// CLIENT version of SendNetworkedVariable.
function GM:SendNetworkedVariable( Ent, Name, Var, storageType )

	storageType = storageType or "var"
	
	local ID = Ent:GetNetworkID()
	
	local storageDest = GAMEMODE.__NetworkData[storageType].Storage
	
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
	end
	if !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
	end
	
	NARWHAL.__NetworkCache[storageDest][ID][Name] = Var
	
end

// CLIENT version of FetchNetworkedVariable.
function GM:FetchNetworkedVariable( Ent, Name, Var, storageType )

	storageType = storageType or "var"
	
	local ID = Ent:GetNetworkID()
	local storageDest = GAMEMODE.__NetworkData[storageType].Storage
	
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
	end
	if !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
	end
	if !NARWHAL.__NetworkCache[storageDest][ID][Name] then
		GAMEMODE:SendNetworkedVariable( Ent, Name, Var, storageType )
		return Var
	end
	
	return NARWHAL.__NetworkCache[storageDest][ID][Name]
	
end

local function UMSG_RecieveVariable( um )
	
	local StorageData = string.Explode( " ", um:ReadString() )
	local ID = StorageData[1]
	local storageType = StorageData[2]
	local Name = StorageData[3]
	local RecieveData = GAMEMODE:GetNetworkConfigurations()[storageType]
	local storageDest = RecieveData.Storage
	local Var = RecieveData.Func_Read( um )
	
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
	end
	if !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
	end
	
	NARWHAL.__NetworkCache[storageDest][ID][Name] = Var
	
end
usermessage.Hook( "NETWORK_SendVariable", UMSG_RecieveVariable )

local function UMSG_RemoveVariable( um )
	
	local StorageData = string.Explode( " ", um:ReadString() )
	local ID = StorageData[1]
	local storageType = StorageData[2]
	local Name = StorageData[3]
	
	local storageDest = GAMEMODE.__NetworkTypeTranslateTable[storageType]
	NARWHAL.__NetworkCache[storageDest][ID][Name] = nil
	
end
usermessage.Hook( "NETWORK_RemoveVariable", UMSG_RemoveVariable )

local function UMSG_RemoveIndex( um )
	
	local ID = um:ReadString()
	
	for k, v in pairs( GAMEMODE.__NetworkData ) do
		if NARWHAL.__NetworkCache[v.Storage][ID] then
			NARWHAL.__NetworkCache[v.Storage][ID] = nil
		end
	end
	
end
usermessage.Hook( "NETWORK_RemoveIndex", UMSG_RemoveIndex )





