--[[-----------------------------------------------------------------------------
  Auth: NightExcessive
  Name: Data Handler
  Desc: Saves and keeps data organized.
-----------------------------------------------------------------------------]]--

local tostring = tostring
local print = print
local error = error
local type = type
local pcall = pcall
local table = table
local string = string
local file = file

MODULE.Name = "narwhal_data" -- The reference name
MODULE.Title = "Data Handler" -- The display name
MODULE.Author = "NightExcessive" -- The author
MODULE.Contact = "nightexcessive@gmail.com" -- The author's contact
MODULE.Purpose = "Save and keep data organized." -- The purpose

MODULE.Resolvers = {}

function MODULE.Resolvers.Player(ply)
	if not ply:IsValid() then return false, "Invalid player" end
	return ply:UniqueID()
end

function MODULE.Resolvers.string(str)
	if str:len() <= 0 then return false, "String must have atleast a length of 1" end
	return str
end

-- Called one time after the module has loaded.
function MODULE:Initialize()
	print(self.Name.." has initialized!")
end

function MODULE:Set(category, key, value)
	key = tostring(key):lower()
	local ct = type(category)
	local resolver = self.Resolvers[ct]
	if type(resolver) ~= "function" then
		error(string.format("bad argument #1 to data:Set (no resolver for %s)", ct), 2)
	end
	local r = {pcall(resolver, category)}
	local s = table.remove(r, 1)
	if not s then
		error(string.format("resolving for type %s failed: %s", ct, r[1]), 2)
	elseif not r[1] then
		error(string.format("resolving for type %s failed: %s", ct, r[2]), 2)
	end
	local filename = string.format("narwhal/%s/%s/%s.txt", self.Name, r[1], key)
	print(string.format("[DEBUG]\twriting %s to %s", value, filename))
	file.Write(filename, glon.encode(value))
end

function MODULE:Get(category, key, default)
	key = tostring(key):lower()
	local ct = type(category)
	local resolver = self.Resolvers[ct]
	if type(resolver) ~= "function" then
		error(string.format("bad argument #1 to data:Set (no resolver for %s)", ct), 2)
	end
	local r = {pcall(resolver, category)}
	local s = table.remove(r, 1)
	if not s then
		error(string.format("resolving for type %s failed: %s", ct, r[1]), 2)
	elseif not r[1] then
		error(string.format("resolving for type %s failed: %s", ct, r[2]), 2)
	end
	local filename = string.format("narwhal/%s/%s/%s.txt", self.Name, r[1], key)
	if not file.Exists(filename) then
		print(string.format("[DEBUG]\t%s doesn't exist", filename))
		return default
	end
	print(string.format("[DEBUG]\t%s exists", filename))
	return glon.decode(file.Read(filename))
end
