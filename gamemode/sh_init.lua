--[[
Name: "sh_init.lua".
	~ Applejack ~
--]]
--[[
14:21 - -{EvO}-'Thorium: Lexi, the timers for the class is not added in the character menu
14:21 - -{EvO}-'Thorium: At least not for citizens
14:22 - -{EvO}-'Thorium: You can only lockpick the guy once, and if he moves the lockpick is unable to pick the lock..
14:22 - -{EvO}-'Thorium: And unable to pick the lock on the same thing again.
14:22 - ||VM|| Lexi: hum
14:22 - -{EvO}-'Thorium: At least no message, and it takes ages to unlock it then..
14:24 - -{EvO}-'Thorium: You still have unlimited stamina when arrested
14:24 - -{EvO}-'Thorium: I think the stamina should be 2/3 of the original ones.
14:25 - -{EvO}-'Thorium: then 67% of stamina would be maximum
14:25 - -{EvO}-'Thorium: Since he is chained and stuff
14:26 - -{EvO}-'Thorium: Also
14:26 - -{EvO}-'Thorium: I think you should readd the abbility to freeze chairs
14:26 - -{EvO}-'Thorium: Unless you are also able to freeze cars
14:28 - -{EvO}-'Thorium: Appearantly you can turn 360 degrees when in a chair.
14:28 - -{EvO}-'Thorium: Like having eyes in your back.
14:29 - ||VM|| Lexi: you've always been able to do that
14:29 - -{EvO}-'Thorium: odd
14:29 - -{EvO}-'Thorium: but okay.
14:29 - -{EvO}-'Thorium: Also,
14:29 - -{EvO}-'Thorium: TJ hit crillz with his trabbi, and suddenly he dies..
14:29 - -{EvO}-'Thorium: Doesn't happen multiple times though
14:29 - -{EvO}-'Thorium: and he barely hit him
14:30 - -{EvO}-'Thorium: Also
14:30 - -{EvO}-'Thorium: When you punch stuff
14:30 - -{EvO}-'Thorium: and you have like 3 stamina left
14:31 - -{EvO}-'Thorium: you can still deal a punch with those 3 stamina left.. and the server just crashed..
14:32 - -{EvO}-'Thorium: Anyway
14:32 - -{EvO}-'Thorium: I think we're kindof done.
--]]
function includecs(file)
	include(file);
	AddCSLuaFile(file);
end

GM.Name = "Applejack - Cider Core";
GM.Email = "mwaness@gmail.com";
GM.Author = "Lexi, original gamemode by kuromeku";
GM.Website = "http://www.ventmob.com";
GM.LuaFolder = string.sub(GM.Folder,11,-1)
includecs("timer.lua");
-- Derive the gamemode from sandbox.
DeriveGamemode("Sandbox");
require("datastream")
function math.DecimalPlaces(numb,places)
	return math.Round(numb*10^places)/10^places
end
function validfile(filename) -- A curse brought on by editing things in mac/linux - Unwanted files!
	return filename:sub(1,1) ~= "." and not filename:find"~";
end
-- This makes more sense tbh
function gamemode.Call(name, ...)
	local gm = gmod.GetGamemode() or GM or GAMEMODE or {};
	if (not gm[name]) then
		ErrorNoHalt("Hook called '",name,"' called that does not have a GM: function!\n");
	end
	return hook.Call(name, gm, ...);
end

-- "I do this because I use some of these variable names a lot by habbit." - kuro
-- Left in because shit still uses this that I haven't rewritten yet. - Lexi
for k, v in pairs(_G) do
	if (!tonumber(k) and type(v) == "table") then
		if (!string.find(k, "%u") and string.sub(k, 1, 1) ~= "_") then
			_G[ "g_"..string.upper( string.sub(k, 1, 1) )..string.sub(k, 2) ] = v;
		end
	end
end
--Because some people are numpties and call ValidEntity on non entity objects, so I need to modify what Garry did
--[[---------------------------------------------------------
    Returns true if object is valid (is not nil and IsValid)
---------------------------------------------------------]]--
function IsValid( object )
	local object = object or nil
	local etype = type(object);
	if etype == "number" or etype == "function" or etype == "string" or etype == "boolean" or etype == "thread" then
		error("What the fuck just passed me a non-ent? "..etype,2)
	end
	if (not (object and object.IsValid)) then return false end
	return object:IsValid()	
end
--[[---------------------------------------------------------
    Returns true if entity is valid
---------------------------------------------------------]]--
ValidEntity = IsValid

-- Create the Cider table and the configuration table.
cider = {};

-- Include the configuration and enumeration files.
includecs("sh_enumerations.lua");
includecs("sh_config.lua");

-- Check if we're running on the server.
if (SERVER) then include("sv_config.lua"); end

-- This needs to be here
function GM:LibrariesLoaded()
end

-- Loop through the libraries and include them.
local subd
for k, v in pairs( file.FindInLua(GM.LuaFolder.."/gamemode/libraries/*.lua") ) do
	if (validfile(v)) then
		subd = string.sub(v, 1, 3);
		if (SERVER) then
			if (subd == "sv_") then
				include("libraries/"..v);
			elseif (subd == "sh_") then
				includecs("libraries/"..v);
			else
				AddCSLuaFile("libraries/"..v);
			end
		else
			if (subd == "cl_" or subd == "sh_") then
				include("libraries/"..v);
			end
		end
	end
end

-- Moonshine style loading function to generically load the libraries, metatables and anything else you want that uses that sorta ting.
local function doload(path, name, plural) -- path must be the relative path from the Applejack/gamemode/ folder
	if (path:sub(-1) ~= "/") then
		path = path.."/";
	end
	MsgN("Applejack: Loading "..name.."s");
	local count = 0;
	local subd, fname;
	for k, v in pairs( file.FindInLua(GM.LuaFolder.."/gamemode/"..path.."*.lua") ) do
		if (validfile(v)) then
			subd = v:sub(1, 3);
			fname = v:sub(4,-5);
			if (subd == "sh_") then
				includecs(path..v);
				MsgN(" Loaded the shared "..fname.." "..name..".");
				count = count + 1;
			elseif (SERVER) then
				if (subd == "sv_") then
					include(path..v);
					MsgN(" Loaded the serverside "..fname.." "..name..".");
					count = count + 1;
				elseif (subd == "cl_") then
					AddCSLuaFile(path..v);
				end
			elseif (subd == "cl_") then
				include(path..v);
				count = count + 1;
				MsgN(" Loaded the clientsideside "..fname.." "..name..".");
			end
		end
	end
	MsgN("Applejack: Loaded "..count.." "..name.."s.\n")
end
doload("libraries/",     "Library",   "Libraries");
doload("metatables/",  "Metatable",  "Metatables");
doload("hooks/", "Hook Library", "Hook Libraries");
gamemode.Call("LibrariesLoaded");

-- Check if we're running on the server.
if (SERVER) then
	include("sv_commands.lua")
	include("sv_umsgs.lua")
	AddCSLuaFile("cl_content.lua")
else
	include("cl_content.lua")
end

-- Whoot for Mewnshien libraries
GM:LoadPlugins()
GM:LoadItems();

--This stuff needs to be after plugins but before everything else
includecs("sh_events.lua")
includecs("sh_jobs.lua")


-- Loop through derma panels and include them.
for k, v in pairs( file.FindInLua(GM.LuaFolder.."/gamemode/derma/*.lua") ) do
	if (validfile(v)) then
		if (CLIENT) then
			include("derma/"..v);
		else
			AddCSLuaFile("derma/"..v);
		end
	end
end

--A few things need to be shared
function util.IsWithinBox(topleft,bottomright,pos)
	if not (pos.z < math.min(topleft.z, bottomright.z) or pos.z > math.max(topleft.z, bottomright.z) or
			pos.x < math.min(topleft.x, bottomright.x) or pos.x > math.max(topleft.x, bottomright.x) or
			pos.y < math.min(topleft.y, bottomright.y) or pos.y > math.max(topleft.y, bottomright.y)) then
		return true
	end
end

-- Called when a bullet tries to ricochet
function GM:CanRicochet(trace,force,swep)
	return force > 5
end
-- Called when a bullet tries to penetrate
function GM:CanPenetrate(trace,force,swep)
	return force > 7.5
end

function GM:ShouldCollide(one,two)
	if (not (one:IsValid() and two:IsValid())) then return true; end
	return not (one:GetClass() == "cider_item" and two:GetClass() == "cider_item");
end

timer.Simple(0,function() GM = GAMEMODE end); -- FUCK YOUR 'GAMEMODE' VAR GARRY

function GM:GetEntityName()
end