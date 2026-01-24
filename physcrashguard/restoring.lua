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
local SetRenderMode = CEntity.SetRenderMode
local SetColor4Part = CEntity.SetColor4Part
local DrawShadow = CEntity.DrawShadow

local GetEntityTable = CEntity.GetTable
local GetPhysicsObject = CEntity.GetPhysicsObject


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

	SetCollisionGroup( pEntity, ptPhysHangDetails.iLastEntityCollisionGroup )

	local ptLastColor = ptPhysHangDetails.tLastEntityColor
	SetRenderMode( pEntity, ptPhysHangDetails.iLastEntityRenderMode )
	SetColor4Part( pEntity, ptLastColor[1], ptLastColor[2], ptLastColor[3], ptLastColor[4] )

	DrawShadow( pEntity, true )

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
