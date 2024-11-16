--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––

	Detecting physics hang & Dealing with problematic objects

–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Prepare
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
--
-- Metamethods: Entity, PhysObj
--
local GetEntityTable	= FindMetaTable( 'Entity' ).GetTable
local IsRagdoll			= FindMetaTable( 'Entity' ).IsRagdoll


local VPhysicsGetEntity		= FindMetaTable( 'PhysObj' ).GetEntity
local VPhysicsIsPenetrating	= FindMetaTable( 'PhysObj' ).IsPenetrating

--
-- Globals
--
local IsThereHang		= physcrashguard.IsThereHang
local PhysIterator		= physcrashguard.Iterator
local Resolve			= physcrashguard.Resolve
local ResolveRagdoll	= physcrashguard.ResolveRagdoll


--[[–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––
	Purpose: Detect hang and deal with it
–––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––––]]
function physcrashguard.DetectHang()

	if ( IsThereHang() ) then

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


local DetectHang = physcrashguard.DetectHang

hook.Add( 'Think', 'PhysicsCrashGuard_DetectHang', function()

	DetectHang()

end )
