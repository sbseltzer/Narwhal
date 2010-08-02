
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

local somthin1 = MODULE.Require( "somemodule1" )
--local somthin2 = MODULE..Require( "somemodule2" )

// Called one time after the module has loaded.
function MODULE:Initialize()
	print( self.Name.." has initialized!" )
	--somthin1:PrintString( "Hello world", self.Name )
	--somthin2:PrintString( "Hello world", self.Name )
end

// Here's a module hook.
function MODULE:Think()
end

// Here's a module hook.
function MODULE:MyThink()
end
MODULE:Hook( "Think", "MyThink", MODULE.MyThink )

// Here's a module hook.
local function MyThink()
end
MODULE:Hook( "Think", "MyThink2", MyThink )

--NARWHAL.RegisterModule( MODULE )
