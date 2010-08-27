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
local concommand = concommand
local string = string
local player = player
local table = table
local timer = timer
local umsg = umsg
local type = type
local pairs = pairs
local error = error
local unpack = unpack
local tostring = tostring
local ErrorNoHalt = ErrorNoHalt
local ValidEntity = ValidEntity
local RecipientFilter = RecipientFilter

local function CheckForConfirmation( ply, Ent, Name, storageType, storageDest, retries, tSendData )
	local ID = Ent:GetNetworkID()
	if !ply then
		local msg
		if retries > 0 then
			msg = "Retried "..retries.." time(s) before failure. Connection lost?"
		else
			msg = "The player was never valid."
		end
		ErrorNoHalt( "Sending of networked "..storageType.." '"..Name.."' on "..tostring(Ent).." failed for "..tostring(ply).." because they are invalid. "..msg.."\n" )
		return
	end
	
	if !NARWHAL.__NetworkCache[storageDest] or !NARWHAL.__NetworkCache[storageDest][ID] or !NARWHAL.__NetworkCache[storageDest][ID][Name] or !NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting or !table.HasValue( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, ply ) then
		return
	end
	
	local maxRetries, retryDelay, retryAgain = 30, 0.1, 3
	if retries < maxRetries then
		if retries >= 4 then
			ErrorNoHalt( "Sending of networked "..storageType.." '"..Name.."' on "..tostring(Ent).." failed for "..tostring(ply).." after "..retries.." retries.\n" )
		end
		timer.Simple( retryDelay, CheckForConfirmation, ply, Ent, Name, storageType, storageDest, retries + 1, tSendData )
	elseif retries == maxRetries then
		ErrorNoHalt( tostring(ply).." may be having connection problems. Will reattempt in "..retryAgain.." seconds.\n" )
		timer.Simple( retryAgain, CheckForConfirmation, ply, Ent, Name, storageType, storageDest, retries + 1, tSendData )
	else
		ErrorNoHalt( "Reattempting network syncronization for "..tostring(ply).."...\n" )
		GAMEMODE:SendNetworkedVariable( unpack( tSendData ) )
	end
	
end

// SERVER version of SendNetworkedVariable.
function GM:SendNetworkedVariable( Ent, Name, Var, storageType, Filter )
	
	storageType = storageType or "var"
	
	local Config = NARWHAL.__NetworkData[storageType]
	local storageDest = Config.Storage
	local ID = Ent:GetNetworkID()
	
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
	end
	
	if !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
	end
	
	if !NARWHAL.__NetworkCache[storageDest][ID][Name] then
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
	end
	
	Filter = Filter or NARWHAL.__NetworkCache[storageDest][ID][Name].Filter or player.GetAll()
	
	if type(Filter) != "table" then
		Filter = {Filter}
	end
	
	NARWHAL.__NetworkCache[storageDest][ID][Name].Filter = Filter -- Update the filter settings.
	NARWHAL.__NetworkCache[storageDest][ID][Name].Value = Var -- Set the var
	
	Var = Config.Func_Check( Var )
	if !Var then return end
	
	if NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting then
		for k, v in pairs( Filter ) do
			if table.HasValue( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, v ) then
				table.remove( Filter, k )
			end
		end
	end
	
	umsg.Start( "NETWORK_SendVariable", Filter )
		umsg.Short( Ent:EntIndex() )
		umsg.Char( NARWHAL.__NetworkTypeID2[storageType] - 129)
		umsg.String( Name )
		Config.Func_Send( Var )
	umsg.End()
	
	NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting = {}
	
	for k, v in pairs( Filter ) do
		table.insert( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, v )
		CheckForConfirmation( v, Ent, Name, storageType, storageDest, 0, {Ent, Name, Var, storageType, Filter} )
	end
	
end

// SERVER version of FetchNetworkedVariable.
function GM:FetchNetworkedVariable( Ent, Name, Var, storageType, Filter )
	
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
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
		Filter = Filter or NARWHAL.__NetworkCache[storageDest][ID][Name].Filter or player.GetAll()
		GAMEMODE:SendNetworkedVariable( Ent, Name, Var, storageType, Filter )
		return Var
	end
	
	return NARWHAL.__NetworkCache[storageDest][ID][Name].Value
	
end

function GM:RemoveNetworkedVariables( Ent )

	umsg.Start( "NETWORK_RemoveIndex" )
		umsg.String(Ent:GetNetworkID())
	umsg.End()
	
	for k, v in pairs( NARWHAL.__NetworkData ) do
		if NARWHAL.__NetworkCache[v.Storage][Ent:GetNetworkID()] then
			NARWHAL.__NetworkCache[v.Storage][Ent:GetNetworkID()] = nil
		end
	end
	
end


local function ConfirmRecievedVar( ply, cmd, args )

	local ID, Name, storageType, storageDest, Key = unpack( args )
	local Ent = Entity(tonumber(ID))
	ID = Ent:GetNetworkID()
	if !NARWHAL.__NetworkCache[storageDest] or !NARWHAL.__NetworkCache[storageDest][ID] or !NARWHAL.__NetworkCache[storageDest][ID][Name] or !NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting or !table.HasValue( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, ply ) then
		return
	end
	
	for k, v in pairs( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting ) do
		if v == ply then
			table.remove( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, k )
			break
		end
	end
	
	MsgN( "Player has confirmed the recieved variable!" )
	
end
concommand.Add( "narwhal_nw_confirmrecievedvar", ConfirmRecievedVar )