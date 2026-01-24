--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Detecting physics hang & Dealing with problematic objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Intermediate variable
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_bResolveScheduled = false

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Parameter
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local g_flHangThreshold

-- Configurational ConVar
do

	local physcrashguard_hangthreshold = CreateConVar(
		'physcrashguard_hangthreshold', '15',
		FCVAR_ARCHIVE,
		'Threshold for counting last physics simulation duration as physics hang, in ms.',
		4, 2000
	)

	g_flHangThreshold = physcrashguard_hangthreshold:GetFloat() / 1000

	cvars.AddChangeCallback( 'physcrashguard_hangthreshold', function( _, _, value )

		g_flHangThreshold = ( tonumber( value ) or 15 ) / 1000

	end, 'PhysCrashGuard' )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Checks for hang in physics simulation
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function PhysCrashGuard.HangTest()

	if ( g_bResolveScheduled ) then
		return true
	end

	return physenv.GetLastSimulationTime() > g_flHangThreshold

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Resolves physics hang
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local PhysCollector = PhysCrashGuard.PhysCollector
local ResolveRagdoll = PhysCrashGuard.ResolveRagdoll
local ResolveSimple = PhysCrashGuard.ResolveSimple

local CEntity = FindMetaTable( 'Entity' )
local IsRagdoll = CEntity.IsRagdoll
local GetEntityTable = CEntity.GetTable

function PhysCrashGuard.ResolveHang()

	--
	-- Schedule the resolve
	--
	if ( not g_bResolveScheduled ) then

		physenv.SetPhysicsPaused( true )
		g_bResolveScheduled = true

		return

	end

	--
	-- The main action
	--
	g_bResolveScheduled = false

	local array = PhysCollector()

	for _, pPhysObj in ipairs( array ) do

		local pEntity = pPhysObj:GetEntity()

		if ( IsRagdoll( pEntity ) ) then

			local pPhysPart = pPhysObj
			local pRagdoll = pEntity

			if ( pPhysPart:IsPenetrating() ) then
				ResolveRagdoll( pPhysPart, pRagdoll, GetEntityTable( pRagdoll ) )
			end

			continue

		end

		if ( pPhysObj:IsPenetrating() ) then
			ResolveSimple( pPhysObj, pEntity, GetEntityTable( pEntity ) )
		end

	end

	do

		local i = #array

		::clear::
		array[i] = nil
		if ( i ~= 0 ) then i = i - 1; goto clear end

		array = nil

	end

	physenv.SetPhysicsPaused( false )

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Convenience function around the two previous
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local HangTest = PhysCrashGuard.HangTest
local ResolveHang = PhysCrashGuard.ResolveHang

function PhysCrashGuard.Scan()

	if ( HangTest() ) then
		ResolveHang()
	end

end

--
-- Integrate
--
hook.Add( 'Think', 'PhysCrashGuard_Scan', function()

	PhysCrashGuard.Scan()

end )
