--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Physics Crash Guard

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Init
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
physcrashguard = physcrashguard or {}

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Assemble the addon
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
