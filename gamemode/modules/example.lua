
/*-----------------------------------------------------------------------------
  Auth: Grea$eMonkey
  Name: Example Module
  Desc: Example module to illustrate how modules are made.
-----------------------------------------------------------------------------*/

MODULE.Name = "myexamplemodule" -- The reference name
MODULE.Title = "Example Module" -- The display name
MODULE.Author = "Grea$eMonkey" -- The author
MODULE.Contact = "geekwithalife@gmail.com" -- The author's contact
MODULE.Purpose = "Just an example module to figure out the framework design from." -- The purpose
MODULE.AutoHook = true
//MODULE.ConfigName = "UseExampleModule" -- Now if you do NARWHAL.Config.UseExampleModule = false, it will disable the use of this module.

--MODULE.Require( "narwhal_currency" )

// Called one time after the module has loaded.
function MODULE:Init()
	print( self.Name.." has been loaded!" ) -- Even though this is hooked to a gamemode method, it still uses the MODULE table as 'self'!
end

function MODULE:Initialize()
	print( self.Name.." has initialized!" ) -- Even though this is hooked to a gamemode method, it still uses the MODULE table as 'self'!
	--self:GetDependency("narwhal_currency"):CreateCurrency( "lol", "set", "get", "add", "take", "give" )
end
/*
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
*/