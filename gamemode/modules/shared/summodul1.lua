
/*-----------------------------------------------------------------------------
  Auth: Grea$eMonkey
  Name: Example Module
  Desc: Example module to illustrate how modules are made.
-----------------------------------------------------------------------------*/

MODULE.Name = "somemodule1" -- The reference name
MODULE.Title = "My Example Module i1" -- The display name
MODULE.Author = "Grea$eMonkey" -- The author
MODULE.Contact = "ssjgamemaker@charter.net" -- The author's contact
MODULE.Purpose = "Just an example module to figure out the framework design from." -- The purpose

--local somthin2 = MODULE.Require (   "somemodule2"  )

// Called one time after the module has loaded.
function MODULE:Initialize()
	print(self.Name.." has initialized!")
	--somthin2:PrintString( "Hello world", self.Name )
end

function MODULE:PrintString( str, origin )
	if origin then
		print( "Module "..origin.." is telling "..self.Name.." to print\t"..str )
	else
		print( "Printing string from "..self.Name..":\t"..str )
	end
end

// Here's a module hook.
function MODULE:Think()
	-- do something
	--print(self.Name.." is thinking!")
end


--NARWHAL.RegisterModule( MODULE )
