--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Detecting physics hang & Dealing with problematic objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local EntityMeta = FindMetaTable( 'Entity' )

local GetEntityTable = EntityMeta.GetTable
local IsRagdoll = EntityMeta.IsRagdoll

--
-- Globals
--
local PhysicsCrashGuard = PhysicsCrashGuard


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

function PhysicsCrashGuard.IsThereHang()

	return PhysEnvGetLastSimulationTime() > g_flHangDetection

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Detect hang and deal with it
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysicsCrashGuard.DetectHang()

	if ( PhysicsCrashGuard.IsThereHang() ) then

		for _, pPhysObj in PhysicsCrashGuard.Iterator() do

			local pEntity = pPhysObj:GetEntity()

			if ( IsRagdoll( pEntity ) ) then

				local pPhysPart = pPhysObj
				local pRagdoll = pEntity

				if ( pPhysPart:IsPenetrating() ) then
					PhysicsCrashGuard.ResolveRagdoll( pPhysPart, pRagdoll, GetEntityTable( pRagdoll ) )
				end

			else

				if ( pPhysObj:IsPenetrating() ) then
					PhysicsCrashGuard.Resolve( pPhysObj, pEntity, GetEntityTable( pEntity ) )
				end

			end

		end

	end

end

hook.Add( 'Think', 'PhysicsCrashGuard_DetectHang', function()

	PhysicsCrashGuard.DetectHang()

end )
