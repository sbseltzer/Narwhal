/*---------------------------------------------------------

	Developer's Notes:
	
	Serverside Networking.
	This sends and synchronizes info to the client.
	
---------------------------------------------------------*/

include( "network_shd.lua" )
AddCSLuaFile( "network_shd.lua" )
AddCSLuaFile( "network_cl.lua" )

local team = team
local umsg = umsg
local table = table
local timer = timer
local string = string
local player = player
local concommand = concommand
local type = type
local pairs = pairs
local error = error
local unpack = unpack
local tonumber = tonumber
local tostring = tostring
local Msg = Msg
local Entity = Entity
local ServerLog = ServerLog
local ErrorNoHalt = ErrorNoHalt
local ValidEntity = ValidEntity
local RecipientFilter = RecipientFilter

// Converts our enums to filter functions
local function FilterEnumToFunction( Ent, Filter )
	if type(Filter) == "number" then
		if !Ent:IsPlayer() or Filter == 0 then
			Filter = player.GetAll
		else
			if Filter == 1 then -- Self
				Filter = function()
					return {Ent}
				end
			elseif Filter == 2 then -- Team
				Filter = function( teamid )
					return team.GetPlayers( teamid )
				end
			elseif Filter == 3 then -- Self's team
				Filter = function()
					return team.GetPlayers( Ent:Team() )
				end
			elseif Filter == 4 then -- Self's opposing teams
				Filter = function()
					local t = {}
					for k, v in pairs( player.GetAll() ) do
						if v:Team() != Ent:Team() then
							table.insert( t, v )
						end
					end
					return t
				end
			end
		end
	end
	return Filter
end

// Converts our filter enums, functions, or players to tables.
local function FilterToTable( Ent, Filter, ... )
	// Now we actually make the filter into a table in case it's not.
	if !Ent then
		print( "Networking Error: Invalid Entity! Using player.GetAll()." )
		return player.GetAll()
	end
	if !Filter then
		print( "Networking Error: Invalid Filter! Using player.GetAll()." )
		return player.GetAll()
	end
	if type( Filter ) == "table" then
		return Filter
	elseif type( Filter ) == "number" then
		return FilterEnumToFunction( Ent, Filter )( ... )
	elseif type(Filter) == "function" then
		return Filter(...)
	elseif type(Filter):lower() == "player" then
		return {Filter}
	else
		print(debug.traceback())
		print( "Networking Error: There was a problem converting the filter to a table!" )
	end
end

// Recursive function to retry for confirmation.
local function CheckForConfirmation( ply, Ent, Name, storageType, storageDest, retries, tSendData )
	
	local ID = Ent:GetNetworkID()
	
	if !NARWHAL.__NetworkCache[storageDest] or !NARWHAL.__NetworkCache[storageDest][ID] or !NARWHAL.__NetworkCache[storageDest][ID][Name] then
		return
	end
	
	if !NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting[1] or !table.HasValue( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, ply ) then
		return
	end
	
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
	
	if ply:IsBot() then
		return
	end
	
	if !ply.ConCommand then
		timer.Simple( 0.5, CheckForConfirmation, ply, Ent, Name, storageType, storageDest, retries, tSendData )
		return
	end
	
	local maxRetries, retryDelay, retryAgain = 4, 1, 1
	if retries < maxRetries then
		NARWHAL:SendCachedVariable( storageDest, ID, Name, ply )
		timer.Simple( retryDelay, CheckForConfirmation, ply, Ent, Name, storageType, storageDest, retries + 1, tSendData )
	elseif retries == maxRetries then
		timer.Simple( retryAgain, CheckForConfirmation, ply, Ent, Name, storageType, storageDest, retries + 1, tSendData )
	else
		NARWHAL:SendCachedVariable( storageDest, ID, Name, ply )
	end
	
end

// Resends a networked var. This calls SendNetworkedVariable with the cached info.
function NARWHAL:ResendNetworkedVariable( Ent, Name, storageType )
	local Config = NARWHAL.__NetworkData[storageType]
	local storageDest = NARWHAL.__NetworkData[storageType].Storage -- Config.Storage
	local Data = NARWHAL.__NetworkCache[storageDest][Ent:GetNetworkID()][Name]
	if !Data then return end
	NARWHAL:SendNetworkedVariable( Ent, Name, Data.Value, storageType, Data.Filter, unpack( Data.FilterArgs ) )
end

// This sends an already cached variable without changing the actual filter and without starting the confimation loop.
function NARWHAL:SendCachedVariable( storageDest, ID, Name, Filter )

	local storageType = "var"
	for k, v in pairs( NARWHAL.__NetworkData ) do
		if v.Storage == storageDest then
			storageType = k
			break
		end
	end
	
	// Make sure all our table members are there.
	if !NARWHAL.__NetworkCache[storageDest] or !NARWHAL.__NetworkCache[storageDest][ID] or !NARWHAL.__NetworkCache[storageDest][ID][Name] then
		return
	end
	
	local Config = NARWHAL.__NetworkData[storageType]
	local Var = Config.Func_Check( NARWHAL.__NetworkCache[storageDest][ID][Name].Value ) -- Check the validity of our var according to our network configurations.
	if !Var then return end -- Nil var? Lets stop here.
	
	local Ent = NARWHAL.__NetworkCache[storageDest][ID][Name].Entity
	Filter = Filter or FilterToTable( Ent, NARWHAL.__NetworkCache[storageDest][ID][Name].Filter, unpack( NARWHAL.__NetworkCache[storageDest][ID][Name].FilterArgs ) )
	
	umsg.Start( "NETWORK_SendVariable", Filter )
		umsg.Short( Ent:EntIndex() ) -- Send an index to identify the entity with on the client.
		umsg.Char( NARWHAL.__NetworkTypeID2[storageType] - 129) -- Yay we're being efficient!
		umsg.String( Name ) -- Send the reference name of the var to identify the variable on the client.
		Config.Func_Send( Var ) -- Send the var according to our network configurations.
	umsg.End()
	
end

// Updates and returns the info for all vars that currently have ply in their filter.
function NARWHAL:GetSubscribedVars( ply )
	NARWHAL.__NetworkSubscriptions[ply] = {}
	local filter
	for storageDest, IDs in pairs( NARWHAL.__NetworkCache ) do
		for ID, Vars in pairs( IDs ) do
			for Name, Info in pairs( Vars ) do
				filter = FilterToTable( Info.Entity, Info.Filter, unpack( Info.FilterArgs ) )
				if table.HasValue( filter, ply ) then
					table.insert( NARWHAL.__NetworkSubscriptions[ply], {storageDest, Info.Type, ID, Name} )
				end
			end
		end
	end
	return NARWHAL.__NetworkSubscriptions[ply]
end

// SERVER version of SendNetworkedVariable.
function NARWHAL:SendNetworkedVariable( Ent, Name, Var, storageType, Filter, ... )
	
	storageType = storageType or "var"
	
	local Config = NARWHAL.__NetworkData[storageType]
	local storageDest = Config.Storage
	local ID = Ent:GetNetworkID()
	
	// Make sure all our table members are there.
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
		NARWHAL.__NetworkCache[storageDest][ID] = {}
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
	elseif !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
	elseif !NARWHAL.__NetworkCache[storageDest][ID][Name] then
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
	end
	
	Var = Var or NARWHAL.__NetworkCache[storageDest][ID][Name].Value -- Make sure we have a var
	
	// First we make sure our filter is converted to the right function in the case that it's an enum. Otherwise, it will just return the last filter setting or the player.GetAll function.
	Filter = FilterEnumToFunction( Ent, Filter or NARWHAL.__NetworkCache[storageDest][ID][Name].Filter ) or player.GetAll -- Filter should default to our last setting or all players.
	
	NARWHAL.__NetworkCache[storageDest][ID][Name].Entity = Ent -- Set the ent for easier reference
	NARWHAL.__NetworkCache[storageDest][ID][Name].Type = storageType -- Set the type for easier reference
	NARWHAL.__NetworkCache[storageDest][ID][Name].Value = Var -- Set the var
	NARWHAL.__NetworkCache[storageDest][ID][Name].Filter = Filter -- Update the filter settings.
	NARWHAL.__NetworkCache[storageDest][ID][Name].FilterArgs = {...} or NARWHAL.__NetworkCache[storageDest][ID][Name].FilterArgs or {} -- Stored arguments for the filter function
	
	// Now we make sure our filter comes out as a table.
	local Filter_Table = FilterToTable( Ent, Filter )
	
	local Var_Encoded = Config.Func_Check( Var ) -- Check the validity of our var according to our network configurations.
	if Var_Encoded == nil then return end -- Nil var? Lets stop here.
	
	// We want to see if we have a waiting list of players already, and if we do, we will want to remove those players from our filter.
	if NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting then -- See if we have a waiting list
		for k, v in pairs( Filter_Table ) do -- Loop through everyone on the filter
			if table.HasValue( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, v ) then
				table.remove( Filter_Table, k ) -- If one of the players from our filter is on the waiting list, remove them from the filter.
			end
		end
	end
	
	// Send the var
	umsg.Start( "NETWORK_SendVariable", Filter_Table )
		umsg.Short( Ent:EntIndex() ) -- Send an index to identify the entity with on the client.
		umsg.Char( NARWHAL.__NetworkTypeID2[storageType] - 129) -- Yay we're being efficient!
		umsg.String( Name ) -- Send the reference name of the var to identify the variable on the client.
		Config.Func_Send( Var_Encoded ) -- Send the var according to our network configurations.
	umsg.End()
	
	// Make the waiting list an empty table since it may not exist yet. If it does, we'd want to clear it anyway.
	NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting = {}
	
	// Since we removed all players on the waiting list from our local filter table, we'll want to add any remaining ones from the filter table to our new waiting list.
	for k, v in pairs( Filter_Table ) do -- Loop through our filter, possibly for the second time. This time it may not have all the original players on it.
		table.insert( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, v ) -- Put all the remaining players on the waiting list.
		// Now we call the recursive confirmation function on each of those players to make sure we didn't miss anyone.
		CheckForConfirmation( v, Ent, Name, storageType, storageDest, 0, { Ent, Name, Var, storageType, Filter, ... } ) -- Check for confirmation on each of the players.
	end
	
end

// SERVER version of FetchNetworkedVariable.
function NARWHAL:FetchNetworkedVariable( Ent, Name, Var, storageType, Filter, ... )
	
	storageType = storageType or "var"
	
	local ID = Ent:GetNetworkID()
	
	local storageDest = NARWHAL.__NetworkData[storageType].Storage
	
	if !NARWHAL.__NetworkCache[storageDest] then
		NARWHAL.__NetworkCache[storageDest] = {}
		NARWHAL.__NetworkCache[storageDest][ID] = {}
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
	elseif !NARWHAL.__NetworkCache[storageDest][ID] then
		NARWHAL.__NetworkCache[storageDest][ID] = {}
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
	elseif !NARWHAL.__NetworkCache[storageDest][ID][Name] then
		NARWHAL.__NetworkCache[storageDest][ID][Name] = {}
		Filter = Filter or NARWHAL.__NetworkCache[storageDest][ID][Name].Filter or player.GetAll
		NARWHAL:SendNetworkedVariable( Ent, Name, Var, storageType, Filter, ... )
		return Var
	end
	
	return NARWHAL.__NetworkCache[storageDest][ID][Name].Value
	
end

// Removes network cache for the ent
function NARWHAL:RemoveNetworkedVariables( Ent )

	umsg.Start( "NETWORK_RemoveIndex" )
		umsg.Short( Ent:EntIndex() )
	umsg.End()
	
	for k, v in pairs( NARWHAL.__NetworkData ) do
		if NARWHAL.__NetworkCache[v.Storage][Ent:GetNetworkID()] then
			NARWHAL.__NetworkCache[v.Storage][Ent:GetNetworkID()] = nil
		end
	end
	
end

// Concommand for starting the confirmation recursion
local function ConfirmReceivedVar( ply, cmd, args )

	local ID, Name, storageType, storageDest = unpack( args )
	
	if !NARWHAL.__NetworkCache[storageDest] or !NARWHAL.__NetworkCache[storageDest][ID] or !NARWHAL.__NetworkCache[storageDest][ID][Name] or !NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting[1] or !table.HasValue( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, ply ) then
		return
	end
	
	for k, v in pairs( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting ) do
		if v == ply then
			table.remove( NARWHAL.__NetworkCache[storageDest][ID][Name].Waiting, k )
			break
		end
	end
	
end
concommand.Add( "narwhal_nw_confirmreceivedvar", ConfirmReceivedVar )

// Concommand for requesting a var from the server - only allowed when the player is in the filter.
local function RequestVar( ply, cmd, args )
	
	local storageDest, storageType, ID, Name = unpack( args )
	local Ent = Entity( tonumber( ID ) )
	ID = Ent:GetNetworkID()
	
	if !NARWHAL.__NetworkCache[storageDest] or !NARWHAL.__NetworkCache[storageDest][ID] or !NARWHAL.__NetworkCache[storageDest][ID][Name] or !table.HasValue( FilterToTable( Ent, NARWHAL.__NetworkCache[storageDest][ID][Name].Filter, unpack( NARWHAL.__NetworkCache[storageDest][ID][Name].Filter.FilterArgs ) ), ply ) then
		Msg( "Player "..tostring(ply).." does not have permission to receive networked "..storageType.." "..Name.." from "..tostring(Ent).."!\n" )
		ServerLog( "Player "..tostring(ply)..":["..ply:SteamID().."] requested networked "..storageType.." "..Name.." from "..tostring(Ent).." at "..os.time().." via concommand without proper permissions!!!" )
		return
	end
	
	NARWHAL:SendCachedVariable( storageDest, ID, Name, ply )
	
end
concommand.Add( "narwhal_nw_requestvar", RequestVar )

// This updates networked vars for new players.
hook.Add( "PlayerAuthed", "NARWHAL.PlayerAuthed.UpdateNWVars", function( ply, SteamID, UniqueID )
	local subscriptions = NARWHAL:GetSubscribedVars( ply )
	if subscriptions and subscriptions[1] then
		umsg.Start( "NETWORK_SendSubscriptions", ply )
			umsg.String( glon.encode( subscriptions ) )
		umsg.End()
	end
end )

// This removes all vars that belong to disconnected players.
hook.Add( "PlayerDisconnected", "NARWHAL.PlayerDisconnected.RemoveNWVars", function( player )
	NARWHAL:RemoveNetworkedVariables( player )
end )


