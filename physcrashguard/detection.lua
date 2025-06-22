--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Detecting physics hang & Dealing with problematic objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity; PhysObj
--
local GetEntityTable = FindMetaTable( 'Entity' ).GetTable
local IsRagdoll = FindMetaTable( 'Entity' ).IsRagdoll

local VPhysicsGetEntity = FindMetaTable( 'PhysObj' ).GetEntity
local VPhysicsIsPenetrating = FindMetaTable( 'PhysObj' ).IsPenetrating

--
-- Globals
--
local physcrashguard = physcrashguard

local PhysIterator		= physcrashguard.Iterator
local Resolve			= physcrashguard.Resolve
local ResolveRagdoll	= physcrashguard.ResolveRagdoll


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Hang detection
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local physcrashguard_hangdetection = CreateConVar(

	'physcrashguard_hangdetection',
	'14',

	FCVAR_ARCHIVE,

	'What delay (ms) in physics simulation will be considered as a physics hang',
	0, 2000

)

local g_flHangDetection = physcrashguard_hangdetection:GetFloat() / 1000

cvars.AddChangeCallback( 'physcrashguard_hangdetection', function( _, _, value )

	g_flHangDetection = ( tonumber( value ) or 14 ) / 1000

end, 'Main' )

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Checks for physics hang
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local PhysEnvGetLastSimulationTime = physenv.GetLastSimulationTime

function physcrashguard.IsThereHang()

	return PhysEnvGetLastSimulationTime() > g_flHangDetection

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Detect hang and deal with it
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.DetectHang()

	if ( physcrashguard.IsThereHang() ) then

		for _, pPhysObj in PhysIterator() do

			local pEntity = VPhysicsGetEntity( pPhysObj )

			if ( IsRagdoll( pEntity ) ) then

				local pPhysPart = pPhysObj
				local pRagdoll = pEntity

				if ( VPhysicsIsPenetrating( pPhysPart ) ) then
					ResolveRagdoll( pPhysPart, pRagdoll, GetEntityTable( pRagdoll ) )
				end

			else

				if ( VPhysicsIsPenetrating( pPhysObj ) ) then
					Resolve( pPhysObj, pEntity, GetEntityTable( pEntity ) )
				end

			end

		end

	end

end

hook.Add( 'Think', 'PhysicsCrashGuard_DetectHang', function()

	physcrashguard.DetectHang()

end )
