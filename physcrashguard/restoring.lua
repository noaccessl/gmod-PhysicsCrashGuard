--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Restoring resolved objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]



--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local CEntity = FindMetaTable( 'Entity' )

local SetCollisionGroup = CEntity.SetCollisionGroup
local SetDrawShadow = CEntity.DrawShadow
local SetColor4Part = CEntity.SetColor4Part
local SetRenderMode = CEntity.SetRenderMode

local GetEntityTable = CEntity.GetTable
local GetPhysicsObject = CEntity.GetPhysicsObject

--
-- Functions
--
local unpack = unpack


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Restoring
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function Restore( pEntity, entity_t, pPhysObj )

	local ptPhysHangDetails = entity_t.m_tPhysHangDetails
	local ptPhysParts = ptPhysHangDetails.tPhysParts

	if ( ptPhysParts ) then

		for i = 1, ptPhysParts[0] do

			local pPhysPart = ptPhysParts[i]

			pPhysPart:EnableMotion( true )
			pPhysPart:Wake()

		end

	else

		pPhysObj:EnableMotion( true )
		pPhysObj:Wake()

	end

	SetDrawShadow( pEntity, true )

	SetColor4Part( pEntity, unpack( ptPhysHangDetails.colEntityLast, 1, 4 ) )
	SetRenderMode( pEntity, ptPhysHangDetails.iEntityLastRenderMode )

	SetCollisionGroup( pEntity, ptPhysHangDetails.iEntityLastCollisionGroup )

	entity_t.m_tPhysHangDetails = nil

end

function PhysCrashGuard.TryToRestore( pEntity )

	local entity_t = GetEntityTable( pEntity )

	if ( entity_t.m_tPhysHangDetails ) then

		local pPhysObj = GetPhysicsObject( pEntity )

		if ( not pPhysObj:IsPenetrating() ) then
			Restore( pEntity, entity_t, pPhysObj )
		end

	end

end

--
-- Integrate
--
hook.Add( 'OnPhysgunPickup', 'PhysCrashGuard_Restore', function( _, pEntity )

	PhysCrashGuard.TryToRestore( pEntity )

end )

hook.Add( 'GravGunOnPickedUp', 'PhysCrashGuard_Restore', function( _, pEntity )

	PhysCrashGuard.TryToRestore( pEntity )

end )

hook.Add( 'GravGunPunt', 'PhysCrashGuard_Restore', function( _, pEntity )

	PhysCrashGuard.TryToRestore( pEntity )

end )
