--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Restoring resolved objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods
--
local EntityMeta = FindMetaTable( 'Entity' )

local SetCollisionGroup = EntityMeta.SetCollisionGroup
local SetDrawShadow     = EntityMeta.DrawShadow
local SetColor4Part     = EntityMeta.SetColor4Part
local SetRenderMode     = EntityMeta.SetRenderMode

local GetEntityTable = EntityMeta.GetTable
local GetPhysicsObject = EntityMeta.GetPhysicsObject

--
-- Functions
--
local unpack = unpack


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Restoring
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
local function Restore( pEntity, entity_t, pPhysObj )

	local tPhysHang = entity_t.m_PhysHang
	local physparts = tPhysHang.m_PhysParts

	if ( physparts ) then

		for i = 1, physparts[0] do

			local pPhysPart = physparts[i]

			pPhysPart:EnableMotion( true )
			pPhysPart:Wake()

		end

	else

		pPhysObj:EnableMotion( true )
		pPhysObj:Wake()

	end

	SetDrawShadow( pEntity, true )

	SetColor4Part( pEntity, unpack( tPhysHang.colEntityLast, 1, 4 ) )
	SetRenderMode( pEntity, tPhysHang.iEntityLastRenderMode )

	SetCollisionGroup( pEntity, tPhysHang.iEntityLastCollisionGroup )

	entity_t.m_PhysHang = nil

end

function PhysicsCrashGuard.TryToRestore( pEntity )

	local entity_t = GetEntityTable( pEntity )
	local pPhysObj = GetPhysicsObject( pEntity )

	if ( entity_t.m_PhysHang and not pPhysObj:IsPenetrating() ) then
		Restore( pEntity, entity_t, pPhysObj )
	end

end

--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Try to restore
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
hook.Add( 'OnPhysgunPickup', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	PhysicsCrashGuard.TryToRestore( pEntity )

end )

hook.Add( 'GravGunOnPickedUp', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	PhysicsCrashGuard.TryToRestore( pEntity )

end )

hook.Add( 'GravGunPunt', 'PhysicsCrashGuard_Restore', function( _, pEntity )

	PhysicsCrashGuard.TryToRestore( pEntity )

end )
