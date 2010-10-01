
/*---------------------------------------------------------

	Developer's Notes:
	
	I figured it would be easier to collaborate if we put
	all of our includes and AddCSLuaFiles in three
	separate files. That way, no one has to edit init.lua,
	cl_init.lua, or shared.lua.
	
	This is where we include serverside files and add
	clientside files.
	
---------------------------------------------------------*/


// Add Resources
resource.AddFile( "models/Skeleton/alyxanimtree.mdl" )
resource.AddFile( "models/Skeleton/combineanimtree.mdl" )
resource.AddFile( "models/Skeleton/maleanimtree.mdl" )
resource.AddFile( "models/Skeleton/femaleanimtree.mdl" )
resource.AddFile( "models/Skeleton/metroanimtree.mdl" )
//resource.AddFile( "models/Skeleton/playeranimtree.mdl" ) -- TODO
//resource.AddFile( "models/Skeleton/l4danimtree.mdl" ) -- TODO

// Include server files
include( 'config.lua' )
include( 'networking/network.lua' )

// Add shared files
AddCSLuaFile( "config.lua" )
AddCSLuaFile( "themes.lua" )
AddCSLuaFile( "modules.lua" )
AddCSLuaFile( "animations.lua" )

// Loads files from the named folder.
local function LoadFiles( state )
	local Folder = string.Replace( GM.Folder, "gamemodes/", "" )
	for c, d in pairs( file.FindInLua( Folder.."/gamemode/"..state.."/*") ) do
		if d:find( ".lua" ) then
			if state:lower() == "client" then
				AddCSLuaFile( Folder.."/gamemode/"..state.."/"..d )
			elseif state:lower() == "server" then
				include( Folder.."/gamemode/"..state.."/"..d )
			elseif state:lower() == "shared" then
				include( Folder.."/gamemode/"..state.."/"..d )
				AddCSLuaFile( Folder.."/gamemode/"..state.."/"..d )
			end
		end
	end
end

// Putting files in the server folder will automatically include the contents.
LoadFiles( "server" )

// Putting files in the client folder will automatically AddCSLuaFile the contents.
LoadFiles( "client" )

// Putting files in the shared folder will automatically include and AddCSLuaFile the contents.
--LoadFiles( "shared" )






