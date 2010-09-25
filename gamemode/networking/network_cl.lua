/*---------------------------------------------------------

	Developer's Notes:
	
	Clientside Networking.
	This receives networked data from the server.

---------------------------------------------------------*/

// Declare frequently used globals as locals to enhance performance
local timer = timer
local string = string
local usermessage = usermessage
local pairs = pairs
local tostring = tostring
local Entity = Entity
local ErrorNoHalt = ErrorNoHalt
local LocalPlayer = LocalPlayer
local RunConsoleCommand = RunConsoleCommand

// CLIENT version of SendNetworkedVariable.
function NARWHAL:SendNetworkedVariable( Ent, Name, Var, storageType )

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
function NARWHAL:FetchNetworkedVariable( Ent, Name, Var, storageType )

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
		if Var == nil then
			error( "Fetching of networked "..storageType.." '"..Name.."' for "..tostring(Ent).." failed. Are they in the network filter for this variable?\n" )
		end
		NARWHAL:SendNetworkedVariable( Ent, Name, Var, storageType )
		return Var
	end
	
	return NARWHAL.__NetworkCache[storageDest][ID][Name]
	
end

// Usermessage Hooks

local function AttemptConfirmation( ID, Name, storageType, storageDest, retries )
	if !LocalPlayer() or !LocalPlayer().ConCommand then
		ErrorNoHalt( "Confirmation of networked "..storageType.." '"..Name.."' on "..ID.." failed for "..tostring( LocalPlayer() ).." after "..retries.." retries.\n" )
		timer.Simple( 0.1, AttemptConfirmation, ID, Name, storageType, storageDest, retries + 1 )
		return
	end
	RunConsoleCommand( "narwhal_nw_confirmreceivedvar", ID, Name, storageType, storageDest )
end

local function AttemptVarRequest( tSubscriptions )
	if !LocalPlayer().ConCommand then
		timer.Simple( 0.1, AttemptVarRequest, tSubscriptions )
		return
	end
	for k, v in pairs( tSubscriptions ) do
		RunConsoleCommand( "narwhal_nw_requestvar", unpack( v ) )
	end
end

local function UMSG_ReceiveVariable( um )

	local index = um:ReadShort()
	local ent = Entity( index )
	local ID = ent:GetNetworkID()
	
	if !ent or ID == "nil" then return end
	
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
	AttemptConfirmation( ID, Name, storageType, storageDest, 1 )
	
end
usermessage.Hook( "NETWORK_SendVariable", UMSG_ReceiveVariable )

local function UMSG_RemoveIndex( um )
	
	local ID = Entity( um:ReadShort() ):GetNetworkID()
	
	for k, v in pairs( NARWHAL.__NetworkData ) do
		if NARWHAL.__NetworkCache[v.Storage][ID] then
			NARWHAL.__NetworkCache[v.Storage][ID] = nil
		end
	end
	
end
usermessage.Hook( "NETWORK_RemoveIndex", UMSG_RemoveIndex )

local function UMSG_ReceiveSubscriptions( um )
	local tSubscriptions = glon.decode( um:ReadString() )
	NARWHAL.__NetworkSubscriptions = tSubscriptions
	AttemptVarRequest( tSubscriptions )
end
usermessage.Hook( "NETWORK_SendSubscriptions", UMSG_ReceiveSubscriptions )



