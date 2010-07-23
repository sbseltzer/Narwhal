
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

MODULE.Require( "somemodule1" ) -- This could be used inside modules to control loading when one fails.

// Here's a module hook.
local function Think( ... )
	-- do something
end
MODULE.Hook( "Think", "MyThink", Think )

// If you want to add values to the object's metatable before it's set, do it here.
function MODULE:SetupObject( obj )
	return obj
end

// Now you make your own function to be called manually that returns a new instance of your module's object.
// This will end up returning the MODULE.Object metatable.
function MODULE.CreateInstance( ... )
	return self:Constructor() -- You need to return self:Constructor() which is internally defined.
end

// The Object table signifies this module's metatable. These are only used when MODULE.CreateObject is true.
// When true, you can add methods to the object's metatable.
function MODULE.Object:ExampleMethod( ... )
	-- something
end





