--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Physics Crash Guard
	 A system that effectively detects and prevents crash attempts via physics objects.

	 GitHub: https://github.com/noaccessl/gmod-PhysicsCrashGuard
	 Steam Workshop: https://steamcommunity.com/sharedfiles/filedetails/?id=3148349097

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Init
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
PhysicsCrashGuard = PhysicsCrashGuard or {}

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Assemble the system
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
if ( SERVER ) then

	include( 'util.lua' )

	include( 'iterator.lua' )

	include( 'resolving.lua' )
	include( 'detection.lua' )
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
