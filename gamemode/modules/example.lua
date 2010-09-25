/*-----------------------------------------------------------------------------
  Auth: Grea$eMonkey
  Name: Example Module
  Desc: Commented example module for Narwhal
-----------------------------------------------------------------------------*/

-- Introduction

-- Welcome to the wonderful world of Narwhal modules. These are pretty similar to regular Lua modules, but with some key differences.
-- The Narwhal module system is designed for clarity and ease-of-use.
-- It's a fairly powerful system which makes it easier for members of a large development team to work separately towards a common goal.
-- This example module is heavily commented, and explains the basic components of a basic Narwhal module.

-- Part 0: Your module file

-- All modules are loaded from the gamemodes/MyGamemode/gamemode/modules/ folder. They are automatically included (and AddCSLuaFile'd in the case of clientside and shared files).
-- If your module is supposed to have a specific state, such as serverside-only, then put it in the modules/server/ folder. There is also a modules/client/ folder for clientside-only files.
-- Modules in the modules/server and modules/client folders are automatically loaded in their respective states (clientside files are automatically AddCSLuaFile'd).
-- Any module file that is in the root modules/ folder will be automatically loaded in the shared lua state. You can always limit certain segments with the SERVER and CLIENT checks.
-- You could, hypothetically, make two module files with the same MODULE.Name with one in the server state and one in the client state, but with completely different functions and configurations.
-- Note 1: Any series of narwhal based gamemodes that you derive from will load their modules in derivative order before yours. You can, however, disable those modules from loading in your gamemode.
-- Note 2: The file name of your module is not used anywhere in registration. The unique reference name of the module is defined by MODULE.Name.

-- Part 1: Setting up basic variables

MODULE.Name = "example_module" -- This is the module's reference name. This needs to be unique, as it is what will be used to access it as a utility or dependency.
MODULE.Title = "Example Module" -- This is the module's "nice-name".
MODULE.Author = "Grea$eMonkey" -- Author's name.
MODULE.Contact = "geekwithalife@gmail.com" -- Author's contact.
MODULE.Purpose = "Whatever you want." -- Short description of the module's purpose.
--MODULE.ConfigName = "UseExampleModule" -- If you add this, you can disable the module from being loaded on startup by changing NARWHAL.Config["UseExampleModule"] to false. This must be unique!
-- The next two variables are predefined, and true by default. Do not change them unless you need to.
--MODULE.Protect = false -- Change to false if you don't want module functions pcall'd. It is recommended to leave this true. See Part 4 to see how module methods work.
--MODULE.AutoHook = false -- Change to false if you don't want your module methods with gamemode hook names to be autohooked. See Part 5 to learn about how module hooks work.

-- Part 2: Adding dependencies

-- In some cases, you may want your module to use components/resources from other modules.
-- When you want to get a module table in your gamemode, you'd use NARWHAL.GetModule( modName[, opRef] ).
-- However, when you're working inside a module, you need to use MODULE.Require( modName ).
-- The modName should be the reference name which is set by doing MODULE.Name = "modulename".
-- To access the tables of those modules, you use self:GetDependency( modName ) inside your module methods.
-- When you call MODULE.Require, it adds the required module to it's "dependency tree".
-- If one of the modules in your dependency tree fails, any modules that MODULE.Require'd it will also fail.
MODULE.Require( "some_module_01" ) -- The modules you require need to be valid. If it's not, your module will fail.
MODULE.Require( "some_module_02" ) -- If some_module_02 failed for whatever reason, this module would also fail because some_module_02 is now part of it's dependency tree.

-- Due to technical limitations, you can't do something like 'local module1 = MODULE.Require( "some_module_01" )', so here's a workaround.
-- If you want to assign your dependencies to some vars that are native to your module for easy reference, do the following:
local module1, module2 -- These are some blank local variables. We will assign those dependencies to them in the MODULE:Init() function.

-- Part 3: Custom module configurations

-- Setting up custom module configurations is optional.
-- The MODULE.Config table is already valid. You don't need to do MODULE.Config = {} at all.
-- Any members of this table will then be accessible in NARWHAL.Config.Modules["example_module"].
-- If NARWHAL.Config.Modules.example_module..PrintOnThink is true, then MODULE.Config.PrintOnThink. will be changed to true when this module is loaded.
-- The difference between making your own members of the MODULE table for configuration and using the MODULE.Config table is that configurations are automatically loaded from the NARWHAL.Config.Modules table.
MODULE.Config["PrintOnInitialize"] = true -- We would use configurations for logic in our module.
MODULE.Config["PrintOnThink"] = false -- This, for instance, would make it so we don't spam the console with prints on think (see Think hooks below).

-- Part 4: Module methods

-- The idea behind modules, be it a Lua module or from some other programming language, is being able to create a useful interface that can be used without needing to see how it works.
-- This is incredibly useful when working on a development team. Each person writes a module, and all that the other programmers need to know are the names of these functions. Nothing else.
-- This keeps backend data (like local vars) out of the way. Narwhal modules allow you to do that in a safe, protected environment.
-- When MODULE.Protected is true (it is by default), errors will get caught by a protected call.
-- That means the module system won't get totally fucked up by your custom errors.
-- When your module gets loaded (assuming MODULE.Protected is true), every custom function that is a direct member of the MODULE table will be overridden.
-- The original function data gets stored in a table, and the actual function is overridden to use the MODULE:__Call( funcName, ... ) method.
-- MODULE.__Call is used internally to pcall the original function. It will print the error in console with ErrorNoHalt, but with the line numbers and such.
-- MODULE.__Call will not work on any of the internal module functions. These include functions such as Require, GetDependency, any hooked functions, etc.

-- MODULE.Init is a predefined module function. It is called after all modules have been loaded.
function MODULE:Init()
	-- Modules are object oriented, so self is a component of all module methods.
	print( "The Narwhal Module "..self.Name.." has successfully loaded." )
	-- Lets assign our dependencies to those local vars we declared earlier. This isn't neccessary, but it's something you can do.
	-- This, of course, is optional. You can always just use self:GetDependency(modName) or self.Dependency[modName].
	-- It is not recommended to access the table directly since table names could potentially change in later revisions.
	module1, module2 = self:GetDependency("some_module_01"), self:GetDependency("some_module_02") -- We will use these later.
end

-- Here's a generic example method. Modules should be comprised of functions such as this.
-- We will use this simple method to demonstrate how module errors are handled.
function MODULE:AddNumbers( num1, num2 )
	-- In this function we have num1 and num2, and we're going to find their sum. Simple, eh?
	-- Let's make sure we're dealing with valid numbers before adding. If one of the arguments isn't a number, we'll throw an error.
	if !tonumber(num1) or !tonumber(num2) then
		error( "MODULE.AddNumbers failed: Invalid arguments!\n" )
	end
	return num1 + num2
end

-- Part 5: Module Hooks

-- This is another method, but this will get treated as a hook when the module is loaded.
-- Any module method whose name matches a gamemode hook will get autohooked
-- Adding MODULE.AutoHook = false with your other module vars will disable autohooking.
function MODULE:Initialize()
	-- The self variable is still that of the MODULE object, even from gamemode hooks.
	-- If you want to use the gamemode object, use GAMEMODE or gmod.GetGamemode().
	-- As you can see, we use one of our config values here.
	if self.Config.PrintOnInitialize then
		print( "The Narwhal Module "..self.Name.." has called a module hook." )
	end
	-- Let's show off our access to our dependencies by printing some info about them.
	print( "We have dependencies "..module1.Title.." ("..module1.Name..") by "..module1.Author.." and "..module2.Name.." ("..module2.Title..") by "..module2.Author.."!" )
end

-- Here's a nice local function that we're going to hook!
local function SomeThinkHook()
	-- Since this isn't a module method, we can't use self.Name in our string.
	-- We're using our config value here. When we created the value, we made it false by default.
	-- If the gamemode's NARWHAL.Config.Modules.PrintOnThink is true, the config value above will be overridden.
	if self.Config.PrintOnThink then
		print( "Module example_module is thinking!" )
	end
end
-- You're not allowed to use hook.Add in modules! How else can we encapsulate it for you?
-- The hook library is nil while modules are loading.
-- Note: Narwhal module hooks take the unique name and combine it with the module name and a few other things to ensure uniqueness. Don't be afraid to have simple hook names.
MODULE:Hook( "Think", "ModuleThinkHook", SomeThinkHook )

-- Here's a module method that doesn't match a hook, but we want to hook it too!
function MODULE:SomeOtherThinkHook()
	-- Since this is a module method, we can now use self.Name in our string.
	if self.Config.PrintOnThink then
		print( "Module "..self.Name.." is thinking from a method!" )
	end
end
-- We will use MODULE.Hook again, but note the syntax of the function we enter.
-- In this case, we are able to use self in our hooks like when a method gets autohooked.
MODULE:Hook( "Think", "ModuleThinkHook2", MODULE.SomeOtherThinkHook )

-- Part 6: Advanced module usage

-- There is a lot more your can do with modules than making a boring library of functions and methods, but that needs to be up to your own imagination.
-- This next part is for more advanced users. It's a simple concept, but it can get quite complicated.

-- Suppose we wanted to do some kind of object instantiation with our module. Something like vgui.Create with derma elements.
-- Since modules are accessed via NARWHAL.GetModule( modName[, opRef] ), it could look something like this:
-- 	 local mylibrary = NARWHAL.GetModule( modName )
-- 	 local myObject = mylibrary.Create()
--	 myObject:SetName( "whutevar" )
--	 myObject:SetSomethingElse( 1, 2, 3, "WOOT" )
-- So you could basically recreate the vgui library in the form of a narwhal module.

-- Let's create a metatable.
local meta = {}
meta.__index = meta
-- Now let's create a method for it. Just something to set a variable in the object called Name.
meta.SetName = function( self, name )
	self.Name = name
	print( "We set our name to "..name.."!" )
end
-- Now we need a function to instantiate our metatable which will act as our object.
function MODULE.Create()
	-- When this function is called, it will instantiate a new object using the metatable we set up earlier.
	local obj = {}
	setmetatable( obj, meta )
	return obj
end

-- Part 7: The End?

-- Thanks for reading. Now you should have a simple Narwhal module. The rest is up to you.
-- Making your own module is now up to your imagination. Play around with it and experiment. Have some fun!
-- Have any questions or issues?
-- Post in our Facepunch thread (www.facepunch.com/showthread.php?t=992385) or on GModCentral in our Narwhal forum (forums.gmodcentral.com/index.php?/forum/21-narwhal/).




