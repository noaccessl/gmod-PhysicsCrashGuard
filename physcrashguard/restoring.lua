--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Restoring resolved objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity; PhysObj
--
local EntityMeta = FindMetaTable( 'Entity' )

local SetCollisionGroup	= EntityMeta.SetCollisionGroup
local SetDrawShadow		= EntityMeta.DrawShadow
local SetColor4Part		= EntityMeta.SetColor4Part
local SetRenderMode		= EntityMeta.SetRenderMode

local GetEntityTable = EntityMeta.GetTable
local GetPhysicsObject = EntityMeta.GetPhysicsObject

local PhysObjMeta = FindMetaTable( 'PhysObj' )

local VPhysicsEnableMotion = PhysObjMeta.EnableMotion
local VPhysicsWake = PhysObjMeta.Wake

local VPhysicsIsPenetrating = PhysObjMeta.IsPenetrating

--
-- Functions
--
local unpack = unpack


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Restoring
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function Restore( pEntity, pEntity_t, pPhysObj )

	local PhysHang = pEntity_t.m_PhysHang
	local physparts = PhysHang.m_PhysParts

	if ( physparts ) then

		for i = 1, physparts[0] do

			local pPhysPart = physparts[i]

			VPhysicsEnableMotion( pPhysPart, true )
			VPhysicsWake( pPhysPart )

		end

	else

		VPhysicsEnableMotion( pPhysObj, true )
		VPhysicsWake( pPhysObj )

	end

	SetDrawShadow( pEntity, true )

	SetColor4Part( pEntity, unpack( PhysHang.m_colLast, 1, 4 ) )
	SetRenderMode( pEntity, PhysHang.m_iLastRenderMode )

	SetCollisionGroup( pEntity, PhysHang.m_iLastCollisionGroup )

	pEntity_t.m_PhysHang = nil

end

function physcrashguard.TryToRestore( pEntity )

	local pEntity_t = GetEntityTable( pEntity )
	local pPhysObj = GetPhysicsObject( pEntity )

	if ( pEntity_t.m_PhysHang and not VPhysicsIsPenetrating( pPhysObj ) ) then
		Restore( pEntity, pEntity_t, pPhysObj )
	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Try to restore
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
hook.Add( 'OnPhysgunPickup', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	physcrashguard.TryToRestore( pEntity )

end )

hook.Add( 'GravGunOnPickedUp', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	physcrashguard.TryToRestore( pEntity )

end )

hook.Add( 'GravGunPunt', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	physcrashguard.TryToRestore( pEntity )

end )
