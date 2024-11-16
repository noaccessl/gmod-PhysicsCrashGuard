--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Physics Crash Guard
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
physcrashguard = {}

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Hang detection
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local HANG_DETECTION = CreateConVar( 'physcrashguard_hangdetection', '14', SERVER and FCVAR_ARCHIVE or FCVAR_NONE, 'What delay in physics simulation will be considered as a physics hang (in ms)' ):GetFloat()

cvars.AddChangeCallback( 'physcrashguard_hangdetection', function( _, _, new )

	HANG_DETECTION = tonumber( new ) or 14

end, 'CacheValue' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Check for a physics hang
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local VPhysicsGetLastSimulationTime = physenv.GetLastSimulationTime

function physcrashguard.IsThereHang()

	return VPhysicsGetLastSimulationTime() * 1000 > HANG_DETECTION

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Include stuff
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
if ( SERVER ) then

	include( 'iterator.lua' )

	include( 'resolving.lua' )
	include( 'detection.lua' )
	include( 'restoring.lua' )

	include( 'constraints.lua' )

	include( 'gradualunfreezing.lua' )

elseif ( CLIENT ) then

	AddCSLuaFile( 'client/gradualunfreezing.lua' )
	include( 'client/gradualunfreezing.lua' )

	AddCSLuaFile( 'client/settings.lua' )
	include( 'client/settings.lua' )

end
