--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Restoring resolved objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity, PhysObj
--
local ENTITY = FindMetaTable( 'Entity' )

local SetCollisionGroup	= ENTITY.SetCollisionGroup
local SetDrawShadow		= ENTITY.DrawShadow
local SetColor4Part		= ENTITY.SetColor4Part
local SetRenderMode		= ENTITY.SetRenderMode

local GetEntityTable	= ENTITY.GetTable
local GetPhysicsObject	= ENTITY.GetPhysicsObject


local PhysObj = FindMetaTable( 'PhysObj' )

local VPhysicsEnableMotion	= PhysObj.EnableMotion
local VPhysicsWake			= PhysObj.Wake

local VPhysicsIsPenetrating = PhysObj.IsPenetrating

--
-- Globals
--
local unpack = unpack


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Restoring
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function Restore( pEntity, pEntity_t, pPhysObj )

	local PhysHang = pEntity_t.m_PhysHang
	local Parts_t = PhysHang.m_tParts

	if ( Parts_t ) then

		for i = 1, Parts_t[0] do

			local pPhysPart = Parts_t[i]

			VPhysicsEnableMotion( pPhysPart, true )
			VPhysicsWake( pPhysPart )

		end

	else

		VPhysicsEnableMotion( pPhysObj, true )
		VPhysicsWake( pPhysObj )

	end

	SetDrawShadow( pEntity, true )

	SetColor4Part( pEntity, unpack( PhysHang.m_colLast ) )
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
local TryToRestore = physcrashguard.TryToRestore

hook.Add( 'OnPhysgunPickup', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	TryToRestore( pEntity )

end )

hook.Add( 'GravGunOnPickedUp', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	TryToRestore( pEntity )

end )

hook.Add( 'GravGunPunt', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	TryToRestore( pEntity )

end )
