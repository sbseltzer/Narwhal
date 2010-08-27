
if !SinglePlayer() then return end

local map = string.gsub(game.GetMap(), "%.bsp", "")

local function SetupDirs()
	if !file.IsDir( "Narwhal" ) then
		file.CreateDir( "Narwhal" )
		file.CreateDir( "Narwhal/MapEditor" )
		file.CreateDir( "Narwhal/MapEditor/"..map )
		return
	end
	if !file.IsDir( "Narwhal/MapEditor" ) then
		file.CreateDir( "Narwhal/MapEditor" )
		file.CreateDir( "Narwhal/MapEditor/"..map )
		return
	end
	if !file.IsDir( "Narwhal/MapEditor/"..map ) then
		file.CreateDir( "Narwhal/MapEditor/"..map )
	end
end

local function EntityDataToString( ent )
	local function FindType( var )
		return type(var)
	end
	local function DataToString( data )
		local dtype = FindType( data )
		if dtype == "Vector" then
			return "Vector: " .. data.x .. " " .. data.y .. " " .. data.z
		elseif dtype == "Angle" then
			return "Angle: " .. data.pitch .. " " .. data.yaw .. " " .. data.roll
		elseif dtype == "Color" then
			return "Color: " .. data.r .. " " .. data.g .. " " .. data.b .. " " .. data.a
		elseif dtype == "keyvalue" then
			return data[1].." = " .. DataToString( FindType(data[2]), data[2] )
		elseif dtype == "table" then
			return glon.encode( data )
		else
			return data
		end
	end
	local function AddData( data )
		return "\t\""..data[1].."\"\t\""..data[2].."\"\n"
	end
	local t, s = {}, ""
	s = "\"id\"\t\""..ent:EntIndex().."\"\n{"
	s = s.."\t"
	s = s.."}"
	
	local args = {...}
	
	if edit == "class" then
		
		local kv
		if ent and ValidEntity( ent ) then
			kv = ent:GetKeyValues()
			RemoveMapEntity( ent, true )
		elseif type( ent ) == "table" then
			kv = ent.KeyValues
		end
		
		ent = CreateMapEntity( args[1] )
		
		for k, v in pairs( kv ) do
			ent:SetKeyValue( k, v )
		end
		
	elseif edit == "position" then
		
		ent:SetPos( Vector( unpack( value ) ) )
		
	elseif edit == "angles" then
		
		ent:SetAngles( Angle( unpack( value ) ) )
		
	elseif edit == "flag" then
		
		local flags = 0
		for i = 1, table.Count( args ) do
			flags = flags + args[i]
		end
		
		ent:SetKeyValue("spawnflags", flags)
		
	elseif edit == "key" then
	
		local key = args[1]
		local valArgs = table.Copy( args )
		table.remove( valArgs, 1 )
		local value = valArgs
		
		if key == "name" then
			
			ent:SetName( value )
			
		elseif key == "parent" then
			
			ent:SetParent( value )
			
		elseif key == "color" then
			
			ent:SetColor( Color( unpack( value ) ) )
			
		elseif key == "collisiongroup" then
			
			ent:SetCollisionGroup( _G[value] )
			
		elseif key == "material" then
			
			ent:SetMaterial( value )
			
		elseif key == "nwvar" then
			
			ent["SetNW"..value]( unpack( value ) )
			
		elseif key == "dtvar" then
			
			ent["SetDT"..value]( unpack( value ) )
			
		elseif key == "skin" then
			
			ent:SetSkin( value )
			
		elseif key == "command" then
			
			ent[key]( unpack(value) )
			
		else
			
			ent:SetKeyValue( key, value )
			
		end
		
	elseif edit == "io" then
		
	elseif edit == "code" then
		
		ent[args[1]] = args[2]
		
	end
end

SetupDirs()

NARWHAL.__MapEditor = {}
NARWHAL.__MapEditor.Map = map
NARWHAL.__MapEditor.Versions = {}
NARWHAL.__MapEditor.Selected = {}
NARWHAL.__MapEditor.Entities = {}
NARWHAL.__MapEditor.CreateQueue = {}
NARWHAL.__MapEditor.RemoveQueue = {}
NARWHAL.__MapEditor.ValidClasses = {}
NARWHAL.__MapEditor.Configurations = {}

NARWHAL.__MapEditor.Versions[map] = {}
NARWHAL.__MapEditor.ValidClasses["info_player_start"] = {}

// Gives us our map editor table
local function GetMapEditorData()
	return NARWHAL.__MapEditor
end

// Saves map editor data to a text file
local function SaveMap( version )
	SetupDirs()
	local data = GetMapEditorData()
	local write = glon.encode( data )
	file.Write( "Narwhal/MapEditor/"..map.."/"..version..".txt", write )
end

// Loads map editor data from a text file
local function LoadMap( version )
	SetupDirs()
	local filename = "Narwhal/MapEditor/"..map.."/"..version..".txt"
	if !file.Exists( filename ) then
		-- warning?
	end
	local data = GetMapEditorData()
	local read = glon.decode( file.Read( filename ) )
	if NARWHAL.__MapEditor != read then
		-- warning?
	end
	NARWHAL.__MapEditor = read
end

local function LoadVersions()
	SetupDirs()
	local dir = "Narwhal/MapEditor/"..map.."/"
	for k, v in pairs( file.Find( dir ) ) do
		if v != "." and v != ".." then
			
		end
	end
end

// Gets all the valid entity classes that our map editor can modify
local function GetValidClasses()
	return NARWHAL.__MapEditor.ValidClasses
end

// Gets the kind of info you'd see in an FGD
local function GetEntityConfigurations( class )
	return NARWHAL.__MapEditor.Configurations[class]
end

// Sets up the configurations (FGD info) for a specific class
local function SetupEntityConfigurations( class, config )
	table.insert( NARWHAL.__MapEditor.ValidClasses, class )
	NARWHAL.__MapEditor.Configurations[class] = config
end

// Selects an entity
local function SelectEntity( ent )
	NARWHAL.__MapEditor.Selected[ent:EntIndex()] = true
end

// Deselects an entity
local function DeselectEntity( ent )
	NARWHAL.__MapEditor.Selected[ent:EntIndex()] = false
end

// Gets all currently selected entities
local function GetSelected()
	local t
	for i, ent in pairs( NARWHAL.__MapEditor.Selected ) do
		if ent == true then
			table.insert( t, ents.GetByIndex( i ) )
		end
	end
	return t
end

// This will add all of our ents back to the editor and load the map changes we've made
local function LoadEditorEntities()
	LoadMap()
	local data = GetMapEditorData()
	for _, ent in pairs( ents.GetAll() ) do
		if !data.Entities[ent:EntIndex()] and table.HasValue( GetValidClasses(), ent:GetClass() ) then
			AddEntityToEditor( ent, false )
		end
	end
	for k, v in pairs( data.CreateQueue ) do
		CreateMapEntity( v[1], unpack( v[2] ) )
	end
	for k, v in pairs( data.RemoveQueue ) do
		RemoveEntityFromEditor( v[1], unpack( v[2] ) )
	end
end
hook.Add( "InitPostEntity", "NARWHAL.MapEditor.LoadEntities", LoadEditorEntities )

// Adds an entity to our editor where we can edit it
local function AddEntityToEditor( ent, queue, ... )
	NARWHAL.__MapEditor.Entities[ent:EntIndex()] = { Entity = ent }
	if queue then
		table.insert( NARWHAL.__MapEditor.CreateQueue, { ent:GetTable(), { ... } } )
	end
end

// Removes an entity
local function RemoveEntityFromEditor( ent, queue )
	if queue then
		table.insert( NARWHAL.__MapEditor.RemoveQueue, ent )
	end
	NARWHAL.__MapEditor.Entities[ent:EntIndex()] = nil
	SafeRemoveEntity( ent )
end

// Removes an entity
local function RemoveMapEntity( ent, queue )
	if queue then
		table.insert( NARWHAL.__MapEditor.RemoveQueue, ent )
	end
	NARWHAL.__MapEditor.Entities[ent:EntIndex()] = nil
	SafeRemoveEntity( ent )
end

// Creates the actual entity with the option of running a series of commands before it spawns
local function CreateMapEntity( class, ... )
	local ent = ents.Create( class )
	if !ent or !ValidEntity( ent ) then return end
	local commands = {...}
	local function CallMethods( commands )
		if table.Count( commands ) >= 1 then
			for _, method in pairs( commands ) do
				if type( method ) == "string" then
					ent[method]()
				elseif type( method ) == "table" then
					local m = method[1]
					local t = table.Copy( method )
					table.remove( t, 1 )
					local args = t
					ent[m]( unpack( args ) )
				end
			end
		end
	end
	CallMethods( commands )
	ent:Spawn()
	AddEntityToEditor( ent, true )
	return ent
end

// Modifies an entity
local function ModifyMapEntity( ent, edit, ... )
	
	local args = {...}
	
	if edit == "class" then
		
		local kv
		if ent and ValidEntity( ent ) then
			kv = ent:GetKeyValues()
			RemoveMapEntity( ent, true )
		elseif type( ent ) == "table" then
			kv = ent.KeyValues
		end
		
		ent = CreateMapEntity( args[1] )
		
		for k, v in pairs( kv ) do
			ent:SetKeyValue( k, v )
		end
		
	elseif edit == "position" then
		
		ent:SetPos( Vector( unpack( value ) ) )
		
	elseif edit == "angles" then
		
		ent:SetAngles( Angle( unpack( value ) ) )
		
	elseif edit == "flag" then
		
		local flags = 0
		for i = 1, table.Count( args ) do
			flags = flags + args[i]
		end
		
		ent:SetKeyValue("spawnflags", flags)
		
	elseif edit == "key" then
	
		local key = args[1]
		local valArgs = table.Copy( args )
		table.remove( valArgs, 1 )
		local value = valArgs
		
		if key == "name" then
			
			ent:SetName( value )
			
		elseif key == "parent" then
			
			ent:SetParent( value )
			
		elseif key == "color" then
			
			ent:SetColor( Color( unpack( value ) ) )
			
		elseif key == "collisiongroup" then
			
			ent:SetCollisionGroup( _G[value] )
			
		elseif key == "material" then
			
			ent:SetMaterial( value )
			
		elseif key == "nwvar" then
			
			ent["SetNW"..value]( unpack( value ) )
			
		elseif key == "dtvar" then
			
			ent["SetDT"..value]( unpack( value ) )
			
		elseif key == "skin" then
			
			ent:SetSkin( value )
			
		elseif key == "command" then
			
			ent[key]( unpack(value) )
			
		else
			
			ent:SetKeyValue( key, value )
			
		end
		
	elseif edit == "io" then
		
	elseif edit == "code" then
		
		ent[args[1]] = args[2]
		
	end
	
	NARWHAL.__MapEditor.Entities[ent:EntIndex()] = { Entity = ent }
	
end



