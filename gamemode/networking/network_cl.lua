/*---------------------------------------------------------

	Developer's Notes:
	
	Clientside Networking.
	This recieves networked data from the server.

---------------------------------------------------------*/

// Declare frequently used globals as locals to enhance performance
local string = string
local usermessage = usermessage
local pairs = pairs

// CLIENT version of SendNetworkedVariable.
function GM:SendNetworkedVariable( Ent, Name, Var, storageType )

	storageType = storageType or "var"
	
	local ID = Ent:GetNetworkID()
	local storageDest = NARWHAL.__NetworkData[storageType].Storage
	
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
	local storageDest = NARWHAL.__NetworkData[storageType].Storage
	
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
	end
	if !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
	end
	if !NARWHAL.__NetworkCache[storageDest][ID][Name] then
		if !Var then
			ErrorNoHalt( "Fetching of networked "..storageType.." '"..Name.."' for "..tostring(Ent).." failed. Client must not be in the serverside filter for this variable.\n" )
			return
		end
		NARWHAL:SendNetworkedVariable( Ent, Name, Var, storageType )
		return Var
	end
	
	return NARWHAL.__NetworkCache[storageDest][ID][Name]
	
end

// Usermessage Hooks

local function AttemptConfirmation( ID, Name, storageType, storageDest )
	
	if !LocalPlayer().ConCommand then
		timer.Simple( 0.1, AttemptConfirmation, ID, Name, storageType, storageDest )
		return
	end
	
	RunConsoleCommand( "narwhal_nw_confirmrecievedvar", ID, Name, storageType, storageDest )
	
end

local function UMSG_RecieveVariable( um )
	local ent = Entity(um:ReadShort())
	local ID = ent:GetNetworkID()
	local storageType = NARWHAL.__NetworkTypeID[um:ReadChar() + 129]
	local Name = um:ReadString()
	local Config = NARWHAL.__NetworkData[storageType]
	local storageDest = Config.Storage
	local Var = Config.Func_Read( um )
	
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
	end
	if !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
	end
	
	NARWHAL.__NetworkCache[storageDest][ID][Name] = Var
	
	AttemptConfirmation( ent:EntIndex(), Name, storageType, storageDest )
	
end
usermessage.Hook( "NETWORK_SendVariable", UMSG_RecieveVariable )

local function UMSG_RemoveVariable( um )
	
	local StorageData = string.Explode( " ", um:ReadString() )
	local ID = StorageData[1]
	local storageType = StorageData[2]
	local Name = StorageData[3]
	
	local storageDest = NARWHAL.__NetworkData[storageType].Storage
	NARWHAL.__NetworkCache[storageDest][ID][Name] = nil
	
end
usermessage.Hook( "NETWORK_RemoveVariable", UMSG_RemoveVariable )

local function UMSG_RemoveIndex( um )
	
	local ID = um:ReadString()
	
	for k, v in pairs( NARWHAL.__NetworkData ) do
		if NARWHAL.__NetworkCache[v.Storage][ID] then
			NARWHAL.__NetworkCache[v.Storage][ID] = nil
		end
	end
	
end
usermessage.Hook( "NETWORK_RemoveIndex", UMSG_RemoveIndex )



