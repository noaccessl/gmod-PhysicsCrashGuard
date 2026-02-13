--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	A system that effectively detects and prevents crash attempts via physics objects, keeping physics available for all.

	Find on GitHub: https://github.com/noaccessl/gmod-PhysicsCrashGuard
	Get on Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3148349097

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Init
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
PhysCrashGuard = PhysCrashGuard or {}

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Assemble the system
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
if ( SERVER ) then

	--
	-- Main
	--
	include( 'resolvers.lua' ) ; AddCSLuaFile( 'resolvers.lua' )
	include( 'physcollector.lua' )
	include( 'hang.lua' ) ; AddCSLuaFile( 'hang.lua' )
	include( 'restoring.lua' )

	--
	-- Secondary
	--
	include( 'constraints.lua' )

	include( 'gradualunfreezing.lua' )

	include( 'freezedupesonpaste.lua' ) ; AddCSLuaFile( 'freezedupesonpaste.lua' )

	--
	-- Clientside stuff
	--
	AddCSLuaFile( 'client/settings.lua' )

	AddCSLuaFile( 'client/gradualunfreezing.lua' )

elseif ( CLIENT ) then

	--
	-- ConVars Sync with client
	--
	include( 'resolvers.lua' )
	include( 'hang.lua' )

	include( 'freezedupesonpaste.lua' )

	--
	-- Clientside stuff
	--
	include( 'client/settings.lua' )

	include( 'client/gradualunfreezing.lua' )

end
