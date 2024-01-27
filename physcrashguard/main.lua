--[[---------------------------------------------------------------------------
	Physics Crash Guard
---------------------------------------------------------------------------]]
physcrashguard = {}

--[[---------------------------------------------------------------------------
	Hang detection
---------------------------------------------------------------------------]]
local HANG_DETECTION = CreateConVar( 'physcrashguard_hangdetection', '14', FCVAR_ARCHIVE, 'Detection of the physics hang (in ms)' ):GetFloat()

cvars.AddChangeCallback( 'physcrashguard_hangdetection', function( _, _, new )
	HANG_DETECTION = tonumber( new ) or 14
end )

local GetLastSimulationTime = physenv.GetLastSimulationTime

function physcrashguard.IsThereHang()

	return GetLastSimulationTime() * 1000 > HANG_DETECTION

end

--[[---------------------------------------------------------------------------
	Include stuff
---------------------------------------------------------------------------]]
include( 'iterator.lua' )

include( 'resolving.lua' )
include( 'detection.lua' )
include( 'restoring.lua' )

include( 'constraints.lua' )
