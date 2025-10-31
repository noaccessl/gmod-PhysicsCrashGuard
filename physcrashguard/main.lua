--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	A system that effectively detects and prevents crash attempts via physics objects.

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

	include( 'resolvers.lua' )
	include( 'physcollector.lua' )
	include( 'hang.lua' )

	include( 'restoring.lua' )

	include( 'constraints.lua' )

	include( 'gradualunfreezing.lua' )

	include( 'freezedupesonpaste.lua' )

	AddCSLuaFile( 'client/gradualunfreezing.lua' )
	AddCSLuaFile( 'client/settings.lua' )

elseif ( CLIENT ) then

	include( 'client/gradualunfreezing.lua' )
	include( 'client/settings.lua' )

end
