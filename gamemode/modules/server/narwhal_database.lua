
local require = require
local type = type
local error = error
local ErrorNoHalt = ErrorNoHalt
local Msg = Msg
local table = table

require( "mysqloo" )

/*-----------------------------------------------------------------------------
  Auth: Tobba
  Name: Database Module
  Desc: Store stuff with MySQL.
-----------------------------------------------------------------------------*/

MODULE.Name = "narwhal_database" -- The reference name
MODULE.Title = "Database Module" -- The display name
MODULE.Author = "Tobba" -- The author
MODULE.Contact = "" -- The author's contact
MODULE.Purpose = "Store stuff with MySQL." -- The purpose
MODULE.Connection = nil
MODULE.Stack = {}
MODULE.Interp = 1

if !mysqloo then error( "MySQLOO must be installed for "..MODULE.Name.." to run!" ) end

function MODULE:Connect(host, user, pass, db, port)
	host = host or "127.0.0.1"
	if host == "localhost" then
		host = "127.0.0.1"
	end
	if type(host) != "string" then
		error("bad argument #1 to 'Connect' (string expected, got "..type(host)..")", 2)
	end

	user = user or "root"
	if type(user) != "string" then
		error("bad argument #2 to 'Connect' (string expected, got "..type(user)..")", 2)
	end

	pass = pass or ""
	if type(pass) != "string" then
		error("bad argument #3 to 'Connect' (string expected, got "..type(pass)..")", 2)
	end

	db = db or "narwhal"
	if type(db) != "string" then
		error("bad argument #4 to 'Connect' (string expected, got "..type(db)..")", 2)
	end
	
	port = port or 3306
	if type(port) != "number" then
		error("bad argument #4 to 'Connect' (number expected, got "..type(port)..")", 2)
	end
	
	self.Connection = mysqloo.connect(host, user, pass, db, port)
	self.Connection.onFailure = function(_, err)
		ErrorNoHalt("MySQL Connection Error: "..err.."\n")
	end
	self.Connection.onConnected = function()
		Msg("Successfully connected to MySQL server!\n")
	end
	self.Connection:connect()
end

function MODULE:Query(text)
	if type(text) != "string" then
		error("bad argument #1 to 'Query' (string expected, got "..type(text)..")", 2)
	end
	
	local query = self.Connection:query(text)
	query:start()
	query:wait()
	return query:getData()
end

function MODULE:ThreadedQuery(text, callback, data)
	if type(text) != "string" then
		error("bad argument #1 to 'Query' (string expected, got "..type(text)..")", 2)
	end

	if callback != nil and type(callback) != "function" then
		error("bad argument #2 to 'Query' (function or nil expected, got "..type(callback)..")", 2)
	end

	if data != nil and type(data) != "function" then
		error("bad argument #3 to 'Query' (function or nil expected, got "..type(query)..")", 2)
	end
	table.insert(self.Stack, {text, callback, data})
end

function MODULE:Think()
	for i=1, self.Interp do
		local tbl = table.remove(self.Stack, 1)
		if tbl then
			local query = self.Connection:query(tbl[1])
			query.onFailure = function(query, err)
				ErrorNoHalt("MySQL Error: "..err.."\n")
			end
			if tbl[2] then
				query.onSuccess = function(query)
					tbl[2](query:getData())
				end
			end
			if tbl[3] then
				query.onData = function(query, row)
					tbl[3](row)
				end
			end
			query:start()
		end
	end
end