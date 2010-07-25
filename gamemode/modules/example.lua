
/*-----------------------------------------------------------------------------
  Auth: Grea$eMonkey
  Name: Example Module
  Desc: Example module to illustrate how modules are made.
-----------------------------------------------------------------------------*/

MODULE.Name = "myexamplemodule" -- The reference name
MODULE.Title = "My Example Module" -- The display name
MODULE.Author = "Grea$eMonkey" -- The author
MODULE.Contact = "ssjgamemaker@charter.net" -- The author's contact
MODULE.Purpose = "Just an example module to figure out the framework design from." -- The purpose
MODULE.CreateObject = true -- Have an automatically generated object (metatable) for this module?

local somthin1 = MODULE.Require( "somemodule1" )
local somthin2 = MODULE.Require( "somemodule2" )

// Called one time after the module has loaded.
function MODULE:Initialize()
	print(self.Name.." has initialized!")
	somthin1:PrintString( "Hello world", self.Name )
	somthin2:PrintString( "Hello world", self.Name )
end

// Here's a module hook.
function MODULE:Think()
	-- do something
	--print(self.Name.." is thinking from base!")
end

// Here's a module hook.
function MODULE:MyThink()
	-- do something
	--print(self.Name.." is thinking from method hook!")
end
--MODULE.Hook( "Think", "MyThink", MODULE.MyThink )

// Here's a module hook.
local function MyThink( self )
	-- do something
	--print(self.Name.." is thinking from plain hook!")
end
--MODULE.Hook( "Think", "MyThink2", MyThink )

// If you want to add values to the object's metatable before it's set, do it here.
function MODULE:SetupObject( obj )
	obj.Name = "lolerblades"
	return obj
end

// Now you make your own function to be called manually that returns a new instance of your module's object.
// This will end up returning the MODULE.Object metatable.
function MODULE:CreateInstance( ... )
	return self:Constructor() -- You need to return self:Constructor() which is internally defined.
end

// The Object table signifies this module's metatable. These are only used when MODULE.CreateObject is true.
// When true, you can add methods to the object's metatable.
function MODULE.Object:ExampleMethod( ... )
	-- something
end




